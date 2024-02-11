extends Node3D

@export var direction = Vector2.LEFT

func _on_interaction_object_on_interact():
	
	CameraManagerObject.fixed_lerp_length = 6.0
	$Interaction/AlternateCamera.set_active()
	await CameraManagerObject.fixed_lerp_done
	GameManager.move_in_direction(direction)
