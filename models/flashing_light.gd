extends OmniLight3D

@export var flash_length : float = 1.0
@export var off_length : float = 1.0

@export var on_color : Color
@export var off_color : Color

var is_on : bool = true
var counter : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_state(is_on)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	counter += delta
	if is_on and counter > flash_length:
		set_state(false)
	elif not is_on and counter > off_length:
		set_state(true)
		

func set_state(set_on):
	is_on = set_on
	counter = 0
	if is_on:
		light_color = on_color
	else:
		light_color = off_color
	
