extends Node3D

@export_group("Key")
@export var required_key = ""
@export var invert_key_condition = false

@export_group("Position")
@export var required_position = -Vector2i.ONE
@export var invert_position_condition = false
@export var hide_if_not_at_position = false

@export_group("Direction")
@export var require_up = false
@export var require_right = false
@export var require_down = false
@export var require_left = false

@export_group("Behaviour")
@export var show_parent_on_fail = false
@export var show_self_on_fail = false
@export var destroy_self_if_passed = false

signal on_condition_check(passed : bool)
signal on_condition_passed
signal on_condition_failed

func _ready():
	check_condition()

func check_condition():
	var passed : bool = passes_condition()
	on_condition_check.emit(passed)
	
	if show_self_on_fail:
		if passed:
			for child in get_children():
				if (child is CSGShape3D):
					child.use_collision = false
				if (child is CollisionShape3D):
					child.disabled = false
			hide()
		else:
			for child in get_children():
				if (child is CSGShape3D):
					child.use_collision = true
				if (child is CollisionShape3D):
					child.disabled = true
			show()
	
	if show_parent_on_fail:
		if passed:
			get_parent().hide()
		else:
			get_parent().show()
	
	if passed:
		on_condition_passed.emit()
	else:
		on_condition_failed.emit()
	
	if passed and destroy_self_if_passed:
		queue_free()

func passes_condition() -> bool:
	var passed = true
	
	# Key check
	if required_key.length() > 0:
		var has_key = GameManager.does_key_exist(required_key)
		if (invert_key_condition):
			has_key = not has_key
		passed = passed and has_key
	
	# Position check
	if required_position != -Vector2i.ONE:
		var is_position : bool = (GameManager.get_dream_grid().player_position == required_position)
		if (invert_key_condition):
			is_position = not is_position
		if (hide_if_not_at_position && not is_position):
			hide()
			if destroy_self_if_passed:
				queue_free()
		passed = passed and is_position
	
	# Direction checks
	if (require_up && not GameManager.get_current_cell().allow_up
		or require_right && not GameManager.get_current_cell().allow_right
		or require_down && not GameManager.get_current_cell().allow_down
		or require_left && not GameManager.get_current_cell().allow_left):
		passed = false
		
	return passed
