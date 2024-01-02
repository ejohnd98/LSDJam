extends MeshInstance3D

@export var wave_speed = 0.5
@export var wave_magnitude = 0.01
var wave_time = 0

func _process(delta):
	wave_time += delta * wave_speed
	var uv_offset : Vector3
	uv_offset.x = cos(wave_time) * wave_magnitude
	uv_offset.y = sin(wave_time) * wave_magnitude
	
	var material : Material = get_active_material(0)
	material.uv1_offset = uv_offset
