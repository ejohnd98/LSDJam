class_name transition

extends TextureRect

signal transition_mid_point
signal transition_end_point

var viewport_texture : ViewportTexture = texture

var transitioning = false

func transition(to_nightmare : bool = false):
	transitioning = true
	# crossfade:
	if (texture != null):
		var current_image = ImageTexture.create_from_image(texture.get_image())
		texture = current_image
	else:
		transition_mid_point.emit()
		return
	$AnimationPlayer.play("dissolve")
	if to_nightmare:
		$TransitionSoundAlt.play()
	else:
		$TransitionSound.play()
	$AnimationPlayer.seek($AnimationPlayer.current_animation_position, true)
	
	await $AnimationPlayer.animation_finished
	transition_mid_point.emit()
	
func finish_transition():
	$AnimationPlayer.play_backwards("dissolve")
	await $AnimationPlayer.animation_finished
	transition_end_point.emit()
	transitioning = false
	texture = viewport_texture

func set_progress (alpha : float):
	if transitioning:
		return
	var seconds = alpha * $AnimationPlayer.current_animation_length
	$AnimationPlayer.seek(seconds, true)
