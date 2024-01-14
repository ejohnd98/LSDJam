class_name DreamCondition extends Node3D

@export_group("Key Condition")
@export var required_key = ""
@export var pass_if_key_is_present = true

@export_group("Position Condition")
@export var position_condition = -Vector2i.ONE

@export_group("Direction Condition")
@export var require_up = false
@export var require_right = false
@export var require_down = false
@export var require_left = false

@export_group("Fail Behaviour")
@export var destroy_on_fail = false

@export_group("Pass Behaviour")
@export var destroy_on_pass = false

@export_group("Position Required")
@export var required_position = -Vector2i.ONE
@export var destroy_if_not_at_position = true

signal on_condition_check(passed : bool)
signal on_condition_passed
signal on_condition_failed

func _ready():
	check_condition()

func check_condition():
	# Check if condition exists at this position first:
	if required_position != -Vector2i.ONE:
		var is_position : bool = (GameManager.get_dream_grid().player_position == required_position)
		if not is_position and destroy_if_not_at_position:
			queue_free()
			return
	
	var passed : bool = passes_condition()
	on_condition_check.emit(passed)
	
	if passed:
		on_condition_passed.emit()
		if destroy_on_pass:
			queue_free()
	else:
		on_condition_failed.emit()
		if destroy_on_fail:
			queue_free()

func passes_condition() -> bool:
	var passed = true
	
	# Check key if specified
	if not required_key.is_empty():
		var has_key = GameManager.does_key_exist(required_key)
		passed = passed and (has_key == pass_if_key_is_present)
	
	# Check if at position
	if position_condition != -Vector2i.ONE:
		var is_position : bool = (GameManager.get_dream_grid().player_position == position_condition)
		passed = passed and is_position
	
	# Direction checks
	if (require_up && not GameManager.get_current_cell().allow_up
		or require_right && not GameManager.get_current_cell().allow_right
		or require_down && not GameManager.get_current_cell().allow_down
		or require_left && not GameManager.get_current_cell().allow_left):
		passed = false
		
	return passed
