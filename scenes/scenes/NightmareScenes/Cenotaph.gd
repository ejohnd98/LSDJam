extends Node3D

var player : LSDPlayer
@export var pos_curve : Curve
@export var curve_begin_dist = 12.0
@export var curve_end_dist = 28.0

var can_animate_positions = false

func _ready():
	player = GameManager.player
	await get_tree().create_timer(0.4).timeout
	can_animate_positions = true

func _process(delta):
	if not can_animate_positions:
		return
	var player_pos = player.global_position
	player_pos.y = 0.0
	for grave_cell : Node3D in $Node3D.get_children():
		var grave_pos = grave_cell.global_position
		grave_pos.y = 0.0
		var dist = grave_pos.distance_to(player_pos)
		
		var alpha = clampf((dist - curve_begin_dist) / (curve_end_dist - curve_begin_dist), 0.0, 1.0)
		
		grave_cell.set_offset(pos_curve.sample(alpha) * 3.0)
