extends AudioStreamPlayer3D

@export var delay : float = 20.0

func _ready():
	seek(delay)
