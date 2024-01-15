class_name CameraManager extends Node3D

@export var fixed_lerp_length = 1.0

var override_active = false

var player : LSDPlayer
var cam : Camera3D

var current_target : Node3D

var fixed_positions
var original_local_pos : Vector3
var original_local_rot : Vector3

var pos_start : Vector3
var pos_end : Vector3

var rot_start : Vector3
var rot_end : Vector3

var counter = 0.0
var is_lerping = false
var backwards = false

signal fixed_lerp_done

func _process(delta):
	if override_active:
		if fixed_positions and is_lerping:
			counter += delta / fixed_lerp_length
			var lerp_alpha = ease(counter, -2.0)
			if backwards:
				lerp_alpha = 1.0 - lerp_alpha
			
			var curr_rotation : Vector3 = rot_start
			curr_rotation.x = lerp_angle(rot_start.x, rot_end.x, lerp_alpha)
			curr_rotation.y = lerp_angle(rot_start.y, rot_end.y, lerp_alpha)
			curr_rotation.z = lerp_angle(rot_start.z, rot_end.z, lerp_alpha)
			
			cam.global_rotation = curr_rotation
			cam.global_position = pos_start.lerp(pos_end, lerp_alpha)
			if (counter >= 1.0):
				fixed_lerp_done.emit()
				is_lerping = false
			

func set_camera_override(target, fixed_position = true):
	fixed_positions = fixed_position
	player = GameManager.player
	player.set_frozen(true)
	cam = player.get_camera()
	original_local_pos = cam.position
	original_local_rot = cam.rotation
	player.override_camera_handling = true
	override_active = true
	current_target = target
	counter = 0.0
	is_lerping = true
	backwards = false
	
	if (fixed_position):
		pos_start = cam.global_position
		pos_end = target.global_position
		
		rot_start = cam.global_rotation
		rot_end = target.global_rotation
	

func lerp_back_to_player():
	counter = 0.0
	backwards = true
	is_lerping = true

func reset_camera():
	cam.position = original_local_pos
	cam.rotation = original_local_rot
	player.override_camera_handling = false
	player.set_frozen(false)
	override_active = false
	current_target = null
