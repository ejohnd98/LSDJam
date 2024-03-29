class_name LSDPlayer extends RigidBody3D

const RAY_LENGTH = 30
const WALK_SPEED = 2.5
const SPRINT_MOD = 1.8
const BIKE_MOD = 3.0
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

var camera_vertical_offset = 0.0

var override_camera_handling = false

var cam_parent : Node3D
var item_parent : Node3D
var cam : Camera3D

@export var debug_camera_height_override = 0.0

var current_interactable : Area3D = null
signal interactable_changed(interactable)

var flashlight_light

func has_items_equipped() -> bool:
	return PlayerSettings.found_items.size() > 1

func _ready():
	default_footstep_sounds = $AudioStreamPlayer.stream
	default_footstep_volume = $AudioStreamPlayer.volume_db
	default_footstep_pitch = $AudioStreamPlayer.pitch_scale
	
	flashlight_light = $HeldItemPivot/HeldItem/HeldItemDetachedParent/Flashlight/SpotLight3D
	
	cam = $CameraPivot/CameraParent/CameraDetachedParent/Camera3D
	cam_parent = $CameraPivot/CameraParent/CameraDetachedParent
	cam_parent.start_following($CameraPivot/CameraParent)
	
	item_parent = $HeldItemPivot/HeldItem/HeldItemDetachedParent
	item_parent.start_following($HeldItemPivot/HeldItem)
	
	init_items()
	
	#add_found_item("flashlight")

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
	
	if OS.has_feature("editor"):
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
	
	if $CycleItemTimer.is_stopped():
		if event.is_action_pressed("CycleItemRight"):
			cycle_items(1)
		if event.is_action_pressed("CycleItemLeft"):
			cycle_items(-1)
		
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
	
	if camera_vertical_offset < 0.0:
		camera_vertical_offset = minf(camera_vertical_offset + delta * 1.5, 0.0)
		$CameraPivot/CameraParent.position.y = camera_vertical_offset + debug_camera_height_override
		$HeldItemPivot/HeldItem.position.y = -0.291 + camera_vertical_offset

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
				if ground_dist < 0.0:
					camera_vertical_offset = min(ground_dist, camera_vertical_offset)
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
	
	
	
	var move_speed : float = WALK_SPEED * control_modifier
	var is_sprinting = Input.is_action_pressed("Sprint") != PlayerSettings.auto_run
	if (is_sprinting):
		move_speed *= SPRINT_MOD
	
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	
	var is_biking = current_item_node != null and current_item_node.item_name == "bike"
	if is_biking:
		move_speed = BIKE_MOD * WALK_SPEED * control_modifier
		input_dir = Vector2i.UP
	
	var direction : Vector3 = ($CameraPivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	if (Input.is_action_pressed("DebugSprint") and OS.has_feature("editor")):
		#move_speed *= DEBUG_SPRINT_MOD
		move_speed = BIKE_MOD * WALK_SPEED * control_modifier * 1.1
		
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
		if is_biking:
			head_bob_anim.speed_scale = 0.5
		var footstep_volume = default_footstep_volume
		var footstep_pitch = default_footstep_pitch
		if (is_sprinting):
			footstep_volume += 4.0
			footstep_pitch += 0.2
		if is_biking:
			footstep_volume = -80.0
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

var current_item_node : EquippedItem = null
var equipped_item_index = 0
var item_name_dict = {}

func init_items():
	for item : EquippedItem in $HeldItemPivot/HeldItem/HeldItemDetachedParent.get_children():
		print(item.item_name)
		item_name_dict[item.item_name] = item

@onready var flashlight_temp = $HeldItemPivot/HeldItem/HeldItemDetachedParent/Flashlight

func refresh_flashlight_hack():
	pass
	#flashlight_temp.show()
	#await get_tree().create_timer(0.1)
	#flashlight_temp.hide()

func add_found_item(item_name : String, also_equip : bool = true):
	if PlayerSettings.found_items.has(item_name):
		return
	
	GameManager.clear_control_prompts()
	
	PlayerSettings.found_items.append(item_name)
	PlayerSettings.save_settings()
	if also_equip:
		set_current_item(item_name)

func set_current_item(item_name : String):
	if current_item_node != null:
		if current_item_node.is_flashlight:
			current_item_node.rotation.y = -180.0
			current_item_node.position.z = 1.0
			current_item_node.position.y = -4.0
			pass
		else:
			current_item_node.hide()
		current_item_node.unequip_item()
		current_item_node = null
	
	if item_name.is_empty():
		return
	
	current_item_node = item_name_dict[item_name]
	current_item_node.equip_item()
	if not current_item_node.is_flashlight:
		current_item_node.show()
	else:
		current_item_node.rotation.y = 0.0
		current_item_node.position.z = 0.0
		current_item_node.position.y = 0.0
	
	equipped_item_index = PlayerSettings.found_items.find(item_name)
	print("Current item index: " + str(equipped_item_index) + " / " + str(PlayerSettings.found_items.size()))

func cycle_items(direction = 1):
	$CycleItemTimer.start()
	equipped_item_index = wrapi(equipped_item_index + direction, 0, PlayerSettings.found_items.size())
	set_current_item(PlayerSettings.found_items[equipped_item_index])

func unequip_item():
	$CycleItemTimer.start()
	equipped_item_index = 0
	set_current_item(PlayerSettings.found_items[equipped_item_index])

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
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 3
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

func get_camera_parent() -> Node3D:
	return cam_parent

func get_item_parent() -> Node3D:
	return item_parent

func get_camera_target() -> Node3D:
	return $CameraPivot/CameraParent

func get_camera_shake() -> Shaker:
	return cam.get_node("Shaker")

func can_see_point(global_point : Vector3) -> bool:
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_point)
	query.exclude= [self, $CollisionShape3D]
	
	var result = space_state.intersect_ray(query)
	if result:
		return false
	return true
	
