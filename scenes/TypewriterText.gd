class_name TypewriterText extends Control

@export var text_speed = 1.0

var is_typing = false
var is_fading = false
var counter = 0.0
var counter_scale = 1.0

var current_characters = 0

var rng = RandomNumberGenerator.new()
var random_modifier = 1.0

func type_out_text (text_to_display : String):
	if text_to_display.contains("??"):
		$TypewriterSound.pitch_scale = 0.1
	else:
		$TypewriterSound.pitch_scale = 0.95
	
	$AnimationPlayer.stop()
	$TextHoldTimer.stop()
	$Label.visible_ratio = 0.0
	$Label.text = text_to_display
	current_characters = 0
	counter = 0.0
	counter_scale = text_speed * 8.0/float(text_to_display.length())
	is_typing = true

func _process(delta):
	if is_typing:
		if counter < 1.0:
			counter += delta * counter_scale * random_modifier
			$Label.visible_ratio = counter
			if ($Label.visible_characters > current_characters):
				var new_char : String = $Label.text[current_characters+1]
				if (!new_char.strip_edges().is_empty()):
					$TypewriterSound.play()
				current_characters = $Label.visible_characters
				random_modifier = rng.randf_range(0.5, 1.2)
				
		else:
			$TextHoldTimer.start()
			is_typing = false
			is_fading = true

func _on_text_hold_timer_timeout():
	if not is_fading:
		return
	$AnimationPlayer.play("fade_text")
	await $AnimationPlayer.animation_finished
	
	is_fading = false
