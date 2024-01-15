class_name ForcedTransitionArea extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		trigger_transition()

func trigger_transition():
	GameManager.pick_random_dream()
