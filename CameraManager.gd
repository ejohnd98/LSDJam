class_name CameraManager extends Node3D

@export var fixed_lerp_length = 1.0

var override_active = false

var player : LSDPlayer
var cam : Node3D

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

var use_lookat = false
var lookat_target : Node3D
var proxy_lookat = false
var proxy_lookat_node : Node3D

var look_at_offset_x = 0

var following_node = false
var follow_node : Node3D = null

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
		elif use_lookat:
			if (proxy_lookat and proxy_lookat_node != null and lookat_target != null):
				proxy_lookat_node.look_at(lookat_target.position, Vector3.UP)
				cam.rotation.x = proxy_lookat_node.rotation.x + look_at_offset_x
			else:
				if lookat_target != null:
					cam.look_at(lookat_target.position, Vector3.UP)
		elif following_node and follow_node != null:
			
			var alpha = delta * 3.0
			
			var rot_a = cam.global_rotation
			var rot_b = follow_node.global_rotation
			var new_rot = Vector3(lerp_angle(rot_a.x, rot_b.x, alpha), lerp_angle(rot_a.y, rot_b.y, alpha), lerp_angle(rot_a.z, rot_b.z, alpha))
			
			cam.global_rotation = new_rot
			cam.global_position = lerp(cam.global_position, follow_node.global_position, alpha)

func set_camera_override_node(target_node : Node3D):
	following_node = true
	follow_node = target_node
	
	player = GameManager.player
	player.set_frozen(true)
	cam = player.get_camera_target()
	original_local_pos = cam.position
	original_local_rot = cam.rotation
	player.override_camera_handling = true
	override_active = true
	GameManager.hide_interact_text()

func set_camera_override(target, fixed_position = true):
	fixed_positions = fixed_position
	player = GameManager.player
	player.set_frozen(true)
	cam = player.get_camera_target()
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

func set_camera_lookat(target, use_proxy = false):
	use_lookat = true
	lookat_target = target
	
	proxy_lookat = use_proxy
	if proxy_lookat:
		proxy_lookat_node = Node3D.new()
		cam.get_parent().add_child(proxy_lookat_node)
		
		proxy_lookat_node.look_at(lookat_target.position, Vector3.UP)
		look_at_offset_x = cam.rotation.x - proxy_lookat_node.rotation.x
	

func lerp_back_to_player():
	counter = 0.0
	backwards = true
	is_lerping = true

func reset_camera():
	fixed_lerp_length = 1.0
	cam.position = original_local_pos
	cam.rotation = original_local_rot
	player.override_camera_handling = false
	player.set_frozen(false)
	override_active = false
	current_target = null
	use_lookat = false
	if proxy_lookat_node != null:
		proxy_lookat_node.queue_free()
	
	following_node = false
	follow_node = null
