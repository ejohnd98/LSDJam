extends Node

signal on_key_exists
signal on_key_missing

@export var key : String = ""

func _ready():
	if key != "":
		check_key(key)
	
func check_key(key : String) -> bool:
	var has_key = GameManager.does_key_exist(key)
	if has_key:
		on_key_exists.emit()
		return true
	else:
		on_key_missing.emit()
		return false
