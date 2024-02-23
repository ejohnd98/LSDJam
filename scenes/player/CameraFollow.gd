extends Node3D

var follow_node : Node3D
var is_following = false

func start_following(target : Node3D):
	follow_node = target
	await get_tree().create_timer(0.1).timeout
	reparent($"../../..".get_parent(), true)
	is_following = true

func reset_position():
	global_rotation = follow_node.global_rotation
	global_position = follow_node.global_position

func _process(delta):
	if not is_following:
		return
		
	var pos_alpha = delta * 15.0
	var rot_alpha = delta * 18.0
	var rot_a = global_rotation
	var rot_b = follow_node.global_rotation
	var new_rot = Vector3(lerp_angle(rot_a.x, rot_b.x, rot_alpha), lerp_angle(rot_a.y, rot_b.y, rot_alpha), lerp_angle(rot_a.z, rot_b.z, rot_alpha))
	
	global_rotation = new_rot
	global_position = lerp(global_position, follow_node.global_position, pos_alpha)
