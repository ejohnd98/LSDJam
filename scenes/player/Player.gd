class_name LSDPlayer extends RigidBody3D

const RAY_LENGTH = 30
const WALK_SPEED = 2.5
const SPRINT_MOD = 1.8
const DEBUG_SPRINT_MOD = 8
const JUMP_VELOCITY = 3.0
const SENSITIVITY = 0.003
const GAMEPAD_LOOK_MOD = 13.0

@export var ground_snap =  0.05
@export_flags_3d_physics var ground_collision_mask

var is_grounded = false
var vertical_velocity = 0
var velocity = Vector3.ZERO

var is_frozen = false
var control_modifier = 1.0

var default_footstep_volume
var default_footstep_pitch

var default_footstep_sounds : AudioStream

var override_camera_handling = false

var current_interactable : Area3D = null
signal interactable_changed(interactable)

var equipped_item : PlayerItem = null

func _ready():
	default_footstep_sounds = $AudioStreamPlayer.stream
	default_footstep_volume = $AudioStreamPlayer.volume_db
	default_footstep_pitch = $AudioStreamPlayer.pitch_scale

func get_forward_vector():
	return -$CameraPivot.global_transform.basis.z

func get_player_rotation():
	return $CameraPivot.rotation.y

func reset_footstep_sounds():
	$AudioStreamPlayer.stream = default_footstep_sounds

func set_footstep_sounds(footsteps : AudioStream):
	$AudioStreamPlayer.stream = footsteps

func _unhandled_input(event):
	if is_frozen:
		return
	
	if event.is_action_pressed("Debug_Up"):
		GameManager.move_in_direction(Vector2i.UP)
	if event.is_action_pressed("Debug_Right"):
		GameManager.move_in_direction(Vector2i.RIGHT)
	if event.is_action_pressed("Debug_Down"):
		GameManager.move_in_direction(Vector2i.DOWN)
	if event.is_action_pressed("Debug_Left"):
		GameManager.move_in_direction(Vector2i.LEFT)
		
	if event.is_action_pressed("Interact"):
		try_interact()
		
	if event is InputEventMouseMotion and not override_camera_handling:
		var camera_control_mod = control_modifier * control_modifier
		$CameraPivot.rotate_y(-event.relative.x * SENSITIVITY * camera_control_mod *(0.2 + PlayerSettings.mouse_sensitivity * 2.0))
		$CameraPivot/CameraParent.rotate_x(-event.relative.y * SENSITIVITY * camera_control_mod * (0.2 + PlayerSettings.mouse_sensitivity * 2.0))
		$CameraPivot/CameraParent.rotation.x = clamp($CameraPivot/CameraParent.rotation.x, deg_to_rad(-80), deg_to_rad(80))

var held_item_offset

func _process(delta):
	var gamepad_look_dir = Input.get_vector("Look_Left", "Look_Right", "Look_Up", "Look_Down")
	var camera_control_mod = control_modifier * control_modifier
	$CameraPivot.rotate_y(-gamepad_look_dir.x * SENSITIVITY * GAMEPAD_LOOK_MOD * camera_control_mod *(0.2 + PlayerSettings.mouse_sensitivity * 2.0))
	$CameraPivot/CameraParent.rotate_x(-gamepad_look_dir.y * 0.6 * SENSITIVITY * GAMEPAD_LOOK_MOD * camera_control_mod * (0.2 + PlayerSettings.mouse_sensitivity * 2.0))
	$CameraPivot/CameraParent.rotation.x = clamp($CameraPivot/CameraParent.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	$HeldItemPivot.global_rotation = $CameraPivot/CameraParent.global_rotation
	pass

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
	var direction : Vector3 = ($CameraPivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	var move_speed : float = WALK_SPEED * control_modifier
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
		head_bob_anim.speed_scale = (1.1 * move_speed / WALK_SPEED) + 0.1
		var footstep_volume = default_footstep_volume
		var footstep_pitch = default_footstep_pitch
		if (is_sprinting):
			footstep_volume += 4.0
			footstep_pitch += 0.2
		$AudioStreamPlayer.volume_db = footstep_volume
		$AudioStreamPlayer.pitch_scale = footstep_pitch
	elif head_bob_anim.is_playing():
		head_bob_anim.get_animation("bob").loop_mode = 0
		if abs(head_bob_anim.current_animation_position - (head_bob_anim.current_animation_length * 0.5)) < 0.01:
			head_bob_anim.stop()

	position += velocity * delta

func on_footstep():
	if ($AudioStreamPlayer/SoundCooldown.is_stopped() and is_grounded):
		$AudioStreamPlayer.play()
		$AudioStreamPlayer/SoundCooldown.start()

func equip_item(item_to_equip : PlayerItem):
	if equipped_item != null:
		#for now, delete item
		equipped_item.on_unequip.emit()
		equipped_item.queue_free()
	
	item_to_equip.reparent($HeldItemPivot/HeldItem)
	item_to_equip.position = Vector3.ZERO
	item_to_equip.rotation = Vector3.ZERO
	item_to_equip.on_equip.emit()
	equipped_item = item_to_equip

func unequip_item():
	if equipped_item == null:
		return
	
	equipped_item.on_unequip.emit()
	equipped_item.queue_free()
	equipped_item = null

func set_frozen (frozen):
	#$CollisionShape3D.disabled = frozen
	velocity = Vector3.ZERO
	if (frozen):
		$CameraPivot/AnimationPlayer.pause()
	vertical_velocity = 0
	is_frozen = frozen

func limit_controls (control_amount : float):
	control_modifier = clampf(control_amount, 0.0, 1.0)

func set_spawn_position (new_position, new_rotation):
	$CameraPivot.rotation.y = new_rotation.y + PI
	
	#Snap to ground
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(new_position + Vector3.UP, new_position + (Vector3.DOWN * RAY_LENGTH))
	query.exclude = [self, $CollisionShape3D]
	var result = space_state.intersect_ray(query)
	
	if result:
		global_position = result["position"]
		is_grounded = true
		vertical_velocity = 0
	else:
		global_position = new_position
	
func update_current_interactable():
	var space_state = get_world_3d().direct_space_state
	var cam = $CameraPivot/CameraParent/Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 2
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
	return $CameraPivot/CameraParent

func get_camera_shake() -> Shaker:
	return $CameraPivot/CameraParent/Camera3D/Shaker

func can_see_point(global_point : Vector3) -> bool:
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_point)
	query.exclude= [self, $CollisionShape3D]
	
	var result = space_state.intersect_ray(query)
	if result:
		return false
	return true
	
