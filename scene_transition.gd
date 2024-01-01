extends CanvasLayer

@export var animation = "dissolve"

signal transition_mid_point
signal transition_end_point

func transition():
	var img = get_viewport().get_texture().get_image()
	#img.flip_y()
	var screenshot = ImageTexture.create_from_image(img)
	#screenshot.create_from_image(img)
	$dissolve_rect.texture = screenshot
	$AnimationPlayer.play(animation)
	await $AnimationPlayer.animation_finished
	transition_mid_point.emit()
	print("transition finished")


#func change_scene(target: String, type: String = 'dissolve') -> void:
#	if type == 'dissolve':
#		transition_dissolve(target)
#	else:
#		transition_clouds(target)
#
#func transition_dissolve(target: String) -> void:
#	$AnimationPlayer.play('dissolve')
#	await $AnimationPlayer.animation_finished
#	get_tree().change_scene_to_file(target)
#	$AnimationPlayer.play_backwards('dissolve')
#
#func transition_clouds(target: String) -> void:
#	$AnimationPlayer.play('clouds_in')
#	await $AnimationPlayer.animation_finished
#	get_tree().change_scene_to_file(target)
#	$AnimationPlayer.play('clouds_out')
