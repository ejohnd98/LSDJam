extends Node3D

@export var bob_amount = 0.05
@export var bob_speed : float = 2

var init_pos
var counter = 0.0

func _ready():
	init_pos = position

func _process(delta):
	var bob_offset = Vector3.ZERO

	counter += delta * bob_speed
	bob_offset = Vector3.UP * (sin(counter) * bob_amount)
	
	position = init_pos + bob_offset
	
