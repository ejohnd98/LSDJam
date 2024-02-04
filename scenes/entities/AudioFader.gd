extends AudioStreamPlayer

@export var fade_in_time = 0.5
@export var fade_out_time = 2.0
@export var overall_volume = 0.8

var volume_scale = 0.0

var is_fading_out = false
var is_fading_in = false
var destroy_on_fade_out = false

func detach_from_parent():
	reparent(get_parent().get_parent(), true)
	
func _ready():
	volume_db = -80 + (80 * (1.0 - pow(1 - (1.0 * overall_volume), 5)))

func fade_in():
	if not is_fading_out:
		volume_scale = 0.0
		
	is_fading_in = true
	is_fading_out = false

func fade_out(destroy_on_finish = false):
	if not is_fading_in:
		volume_scale = 1.0
	
	destroy_on_fade_out = destroy_on_finish
		
	is_fading_out = true
	is_fading_in = false

func _process(delta):
	if is_fading_in:
		volume_scale += delta / fade_in_time
		if volume_scale >= 1.0:
			volume_scale = 1.0
			is_fading_in = false
		volume_db = -80 + (80 * (1.0 - pow(1 - (volume_scale * overall_volume), 5)))
		
	if is_fading_out:
		volume_scale -= delta / fade_out_time
		if volume_scale <= 0.0:
			volume_scale = 0.0
			is_fading_out = false
			if (destroy_on_fade_out):
				queue_free()
		volume_db = -80 + (80 * (1.0 - pow(1 - (volume_scale * overall_volume), 5)))
	
