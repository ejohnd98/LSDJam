extends Node3D

@export var autoOpen : bool = false
@export var can_be_opened : bool = true

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
	
	is_open = true
	$DoorOpenSound.play()
	on_open_door.emit()
	
func close_door():
	if (is_open):
		$DoorCloseSound.play()
	is_open = false
	on_close_door.emit()

func _on_area_3d_body_entered(body):
	if autoOpen and body.is_in_group("player") and not is_open:
		open_door()


func _on_area_3d_body_exited(body):
	if autoOpen and body.is_in_group("player") and is_open:
		close_door()
