class_name ForcedTransitionArea extends Area3D

@export var force_direction = false
@export var direction : Vector2i
var triggered = true

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(3.0).timeout
	triggered = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("body enetered: " + str(body.name))
		trigger_transition()

func trigger_transition():
	if triggered:
		return
	triggered = true
	if force_direction:
		GameManager.move_in_direction(direction)
	else:
		GameManager.pick_random_dream()
