extends Node3D

@export var dream_name : String = "Beach"

func _ready():
	if not PlayerSettings.has_completed_dream(dream_name):
		queue_free()
