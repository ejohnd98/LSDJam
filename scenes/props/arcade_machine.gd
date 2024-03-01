extends Node3D

@export var direction = Vector2i.UP

@export var can_be_used = true

func _ready():
	set_usable(can_be_used)

func set_usable(can_use : bool):
	can_be_used = can_use
	if can_use:
		$InteractionObject.show()
		$InteractionObject/Collider.disabled = false
		$InvalidInteraction.queue_free()
	else:
		$InteractionObject.hide()
		$InteractionObject/Collider.disabled = true

func _on_interaction_object_on_interact():
	if can_be_used:
		await get_tree().create_timer(1.5).timeout
		GameManager.move_in_direction(direction)


func _refresh_condition():
	await get_tree().create_timer(1.0).timeout
	$DreamCondition.check_condition()
