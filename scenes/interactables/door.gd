extends Node3D

@export var autoOpen : bool = false

signal on_open_door
signal on_close_door

var is_open = false

func toggle_open():
	is_open = not is_open
	if (is_open):
		on_open_door.emit()
	else:
		on_close_door.emit()

func open_door():
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
