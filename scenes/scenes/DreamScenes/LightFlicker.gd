extends OmniLight3D

@export var noise_texture : NoiseTexture2D
@export var speed = 10.0
@export var light_scale = 1.0
@export var light_constant = 0.5
var time_passed = 0.0

func _process(delta):
	time_passed += delta * speed
	var noise_sample = noise_texture.noise.get_noise_1d(time_passed)
	light_energy = light_constant + abs(noise_sample) * light_scale
