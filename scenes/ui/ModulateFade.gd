extends Node

@onready var parent_control : Control = $".."

@export var fade_curve : Curve
@export var length = 0.5

@export var auto_start = false

signal on_finished

var counter = 0.0
var is_playing = false
var fading_in = true

func _ready():
	if auto_start:
		fade_in()

func reset(is_visible : bool):
	if is_visible:
		parent_control.modulate.a = 1.0
	else:
		parent_control.modulate.a = 0.0

func fade_in():
	counter = 0.0
	fading_in = true
	is_playing = true

func fade_out():
	counter = 1.0
	fading_in = false
	is_playing = true

func _process(delta):
	if is_playing:
		if fading_in:
			counter += delta / length
			if counter > 1.0:
				counter = 1.0
				finished()
				
		if not fading_in:
			counter -= delta / length
			if counter < 0.0:
				counter = 0.0
				finished()
		
		parent_control.modulate.a = fade_curve.sample(counter)
	

func finished():
	is_playing = false
	on_finished.emit()
