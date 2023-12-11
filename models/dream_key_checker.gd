extends Node

signal on_key_exists
signal on_key_missing

@export var key : String = ""

func _ready():
	if key != "":
		check_key(key)
	
func check_key(key : String) -> bool:
	var has_key = game_manager.get_game(get_tree()).check_current_dream_for_key(key)
	if has_key != null:
		on_key_exists.emit()
		return true
	else:
		on_key_missing.emit()
		return false
