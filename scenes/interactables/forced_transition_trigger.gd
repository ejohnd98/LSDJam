class_name ForcedTransitionArea extends Area3D

@export var force_direction = false
@export var direction : Vector2i

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("body enetered: " + str(body.name))
		trigger_transition()

func trigger_transition():
	if force_direction:
		GameManager.move_in_direction(direction)
	else:
		GameManager.pick_random_dream()
