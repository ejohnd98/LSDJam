extends Control

@export var zero_pos = Vector2(-5,-5)
@export var step = 30

func set_player_position(pos : Vector2i):
	var pivot_pos = zero_pos + Vector2(pos.x * step, pos.y * step)
	$TextureRect/AimPivot.position = pivot_pos

func set_aim_rotation(rot):
	$TextureRect/AimPivot.rotation = rot

func set_aim_strength(scale):
	$TextureRect/AimPivot/ColorRect.scale.y = scale
