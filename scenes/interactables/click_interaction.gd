class_name click_interaction extends Area3D

@export var one_shot : bool = false
@export var max_interacts : int = -1

var interact_count = 0

signal on_interact

func can_interact_internal() -> bool:
	if one_shot and interact_count > 1:
		return false
	
	if max_interacts > 0 and interact_count >= max_interacts:
		return false
	
	return true

# Override this with any additional requirements
func can_interact(player) -> bool:
	return true

func interact(player):
	if can_interact_internal() && can_interact(player):
		on_interact.emit()
	else:
		print("Tried to interact with " + name + " but FAILED")
