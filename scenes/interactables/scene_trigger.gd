extends Area3D

@export var transition_to: PackedScene

func _on_body_entered(body):
	if body.is_in_group("player"):
		get_tree().get_root().get_node("Game").load_new_scene(transition_to)
