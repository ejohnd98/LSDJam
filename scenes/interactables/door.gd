extends Node3D

@export var autoOpen : bool = false
@export var can_be_opened : bool = true
@export var require_key = false
@export var required_key = ""

signal on_open_door
signal on_close_door

var is_open = false

func set_openable (openable):
	can_be_opened = openable

func toggle_open():
	if (is_open):
		close_door()
	else:
		open_door()

func open_door():
	if not can_be_opened:
		return
	
	if require_key and not $KeyChecker.check_key(required_key):
		return
	
	is_open = true
	on_open_door.emit()
	
func close_door():
	is_open = false
	on_close_door.emit()

func _on_area_3d_body_entered(body):
	if autoOpen and body.is_in_group("player") and not is_open:
		open_door()


func _on_area_3d_body_exited(body):
	if autoOpen and body.is_in_group("player") and is_open:
		close_door()
