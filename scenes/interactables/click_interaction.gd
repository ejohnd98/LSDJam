class_name click_interaction extends Area3D

@export var one_shot : bool = false
@export var max_interacts : int = -1

@export var interact_prompt = "Interact"
@export var show_distorted_text = false

@export var interact_sound : AudioStream

var interact_count = 0

signal on_interact

func _ready():
	if interact_sound != null:
		$InteractSound.stream = interact_sound

func can_interact_internal() -> bool:
	if one_shot and interact_count > 1:
		return false
	
	if max_interacts > 0 and interact_count >= max_interacts:
		return false
	
	if $CooldownTimer != null and not $CooldownTimer.is_stopped():
		return false
	
	return true

# Override this with any additional requirements
func can_interact(player) -> bool:
	return true

func is_interactable(player) -> bool:
	return can_interact(player) and can_interact_internal()

func interact(player):
	if can_interact_internal() && can_interact(player):
		on_interact.emit()
		if $CooldownTimer != null:
			$CooldownTimer.start()
		$InteractSound.playing = true
