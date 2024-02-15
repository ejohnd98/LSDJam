extends Node3D

@export var direction = Vector2.UP

func _on_interaction_object_on_interact():
	
	$Interaction/AlternateCamera.set_active()
	await CameraManagerObject.fixed_lerp_done
	$AnimationPlayer.play("BoatAnim")
	$AudioStreamPlayer.play()
	await $AnimationPlayer.animation_finished
	GameManager.move_in_direction(direction)

func _refresh_condition():
	await get_tree().create_timer(1.0).timeout
	$DreamCondition.check_condition()

func set_usable(usable : bool):
	if usable:
		$Interaction/Collider.disabled = false
		$DreamCondition/Sprite3D.hide()
	else:
		$Interaction/Collider.disabled = true
		$DreamCondition/Sprite3D.show()