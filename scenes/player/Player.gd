class_name LSDPlayer extends RigidBody3D

const RAY_LENGTH = 10
const WALK_SPEED = 2.5
const SPRINT_MOD = 1.8
const DEBUG_SPRINT_MOD = 8
const JUMP_VELOCITY = 3.0
const SENSITIVITY = 0.003

@export var ground_snap =  0.05
@export_flags_3d_physics var ground_collision_mask

var is_grounded = false
var vertical_velocity = 0
var velocity = Vector3.ZERO

var is_frozen = false

var default_footstep_volume
var default_footstep_pitch

var default_footstep_sounds : AudioStream

var override_camera_handling = false

var current_interactable : Area3D = null
signal interactable_changed(interactable)

func _ready():
	default_footstep_sounds = $AudioStreamPlayer.stream
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_footstep_volume = $AudioStreamPlayer.volume_db
	default_footstep_pitch = $AudioStreamPlayer.pitch_scale
	
func get_player_rotation():
	return $CameraPivot.rotation.y

func reset_footstep_sounds():
	$AudioStreamPlayer.stream = default_footstep_sounds

func set_footstep_sounds(footsteps : AudioStream):
	$AudioStreamPlayer.stream = footsteps

func _unhandled_input(event):
	if event.is_action_pressed("Debug_Up"):
		GameManager.move_in_direction(Vector2i.UP)
	if event.is_action_pressed("Debug_Right"):
		GameManager.move_in_direction(Vector2i.RIGHT)
	if event.is_action_pressed("Debug_Down"):
		GameManager.move_in_direction(Vector2i.DOWN)
	if event.is_action_pressed("Debug_Left"):
		GameManager.move_in_direction(Vector2i.LEFT)
		
	if event.is_action_pressed("DebugEsc"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if is_frozen:
		return
	if event.is_action_pressed("Interact"):
		try_interact()
		
	if event is InputEventMouseMotion and not override_camera_handling:
		$CameraPivot.rotate_y(-event.relative.x * SENSITIVITY)
		$CameraPivot/Camera3D.rotate_x(-event.relative.y * SENSITIVITY)
		$CameraPivot/Camera3D.rotation.x = clamp($CameraPivot/Camera3D.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	if is_frozen:
		return
	
	update_current_interactable()
	
	# Perform ground raycast:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position + Vector3.UP, position + Vector3.DOWN * RAY_LENGTH)
	query.exclude= [self, $CollisionShape3D]
	var result = space_state.intersect_ray(query)
	
	if result:
		var is_flat_surface = result["normal"].dot(Vector3.UP) > 0.4
		if is_flat_surface:
			var ground_dist = position.y - result["position"].y
			if ground_dist < ground_snap and $JumpTimer.is_stopped():
				position = result["position"]
				var play_footstep = not is_grounded
				is_grounded = true
				if (play_footstep):
					$AudioStreamPlayer.volume_db = default_footstep_volume + 6.0
					$AudioStreamPlayer.pitch_scale = default_footstep_pitch + 0.2
					on_footstep()
				vertical_velocity = 0
			else:
				is_grounded = false
	
	if Input.is_action_pressed("Jump") and is_grounded and $JumpTimer.is_stopped():
		is_grounded = false
		vertical_velocity = JUMP_VELOCITY
		$JumpTimer.start()
	
	if not is_grounded:
		vertical_velocity -= delta * 9
		position.y += vertical_velocity*delta
	
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = ($CameraPivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var move_speed : float = WALK_SPEED
	var is_sprinting = Input.is_action_pressed("Sprint")
	if (is_sprinting):
		move_speed *= SPRINT_MOD
	
	if (Input.is_action_pressed("DebugSprint")):
		move_speed *= DEBUG_SPRINT_MOD
		
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = lerp(velocity.x, direction.x * move_speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * move_speed, delta * 7.0)
	
	var head_bob_anim = $CameraPivot/AnimationPlayer
	if (input_dir.length() > 0.8 and is_grounded):
		if (not head_bob_anim.is_playing()):
			head_bob_anim.play("bob")
			head_bob_anim.get_animation("bob").loop_mode = 1
		head_bob_anim.speed_scale = 1.25 * move_speed / WALK_SPEED
		var footstep_volume = default_footstep_volume
		var footstep_pitch = default_footstep_pitch
		if (is_sprinting):
			footstep_volume += 4.0
			footstep_pitch += 0.2
		$AudioStreamPlayer.volume_db = footstep_volume
		$AudioStreamPlayer.pitch_scale = footstep_pitch
	elif head_bob_anim.is_playing():
		head_bob_anim.get_animation("bob").loop_mode = 0

	position += velocity * delta

func on_footstep():
	if ($AudioStreamPlayer/SoundCooldown.is_stopped() and is_grounded):
		$AudioStreamPlayer.play()
		$AudioStreamPlayer/SoundCooldown.start()

func set_frozen (frozen):
	$CollisionShape3D.disabled = frozen
	velocity = Vector3.ZERO
	if (frozen):
		$CameraPivot/AnimationPlayer.stop()
	vertical_velocity = 0
	is_frozen = frozen

func set_spawn_position (new_position, new_rotation):
	position = new_position
	$CameraPivot.rotation.y = new_rotation.y + PI
	
	#Snap to ground
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position + Vector3.UP, position + Vector3.DOWN * RAY_LENGTH)
	query.exclude= [self, $CollisionShape3D]
	var result = space_state.intersect_ray(query)
	
	if result:
		var is_flat_surface = result["normal"].dot(Vector3.UP) > 0.4
		if is_flat_surface:
			position = result["position"]
			is_grounded = true
			vertical_velocity = 0
	
func update_current_interactable():
	var space_state = get_world_3d().direct_space_state
	var cam = $CameraPivot/Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	if (not result.is_empty() and not override_camera_handling):
		var hit_object = result["collider"]
		if (hit_object.is_in_group("interactable") and hit_object.is_interactable(self)):
			if (current_interactable != hit_object):
				current_interactable = hit_object
				interactable_changed.emit(current_interactable)
			return
	if (current_interactable != null):
		current_interactable = null
		interactable_changed.emit(null)

func try_interact():
	if current_interactable != null:
		current_interactable.interact(self)

func get_camera() -> Camera3D:
	return $CameraPivot/Camera3D
