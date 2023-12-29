class_name game_manager
extends Node3D

const SCENE_PATH = "res://scenes/scenes/"

@export var default_scene: String = "default_scene"

@export var dreams: Array[PackedScene] = []

var current_dream : Control = null
var dream_index = -1

@onready var dream_grid : DreamGrid = get_tree().get_root().get_node("SubViewportContainer/CanvasLayer/DreamGrid")
@onready var canvas_layer = get_tree().get_root().get_node("SubViewportContainer/SubViewport/CanvasLayer")
@onready var player = get_tree().get_root().get_node("SubViewportContainer/SubViewport/Player")

var current_scene_node = null
var next_scene_path = ""

static func get_game(tree_node : SceneTree) -> game_manager:
	return tree_node.get_root().get_node("SubViewportContainer/SubViewport/Game")

var is_ui_shown = true
func _unhandled_input(event):
	if event.is_action_pressed("Hide UI"):
		if is_ui_shown:
			dream_grid.hide()
			$"../../CanvasLayer/Compass".hide()
		else:
			dream_grid.show()
			$"../../CanvasLayer/Compass".show()

func _ready():
	advance_dream()
	
func move_in_direction(direction: Vector2i):
	if (not is_direction_allowed(direction)):
		return
		
	var current_cell = dream_grid.get_current_cell()
	if current_cell.is_goal:
		advance_dream()
		return
	
	if current_cell.is_nightmare:
		var start_cell = dream_grid.get_start_cell()
		dream_grid.player_position = start_cell.grid_position
		dream_grid.update_player_icon()
		load_new_scene(start_cell.scene_name)
		return
	
	dream_grid.move_in_direction(direction)
	load_new_scene(dream_grid.get_scene_from_position())

func advance_dream():
	if dream_index + 1 == dreams.size():
		canvas_layer.get_node("WinScreen").visible = true
		player.set_frozen(true)
		return
	dream_index += 1
	
	#remove old dream grid
	if dream_grid:
		dream_grid.queue_free()
		dream_grid = null
	
	#add new dream grid
	var new_dream = dreams[dream_index].instantiate()
	get_tree().get_root().get_node("SubViewportContainer/CanvasLayer").add_child(new_dream)
	dream_grid = new_dream
	dream_grid.initialize_grid()
	
	#load starting scene
	load_new_scene(dream_grid.get_start_cell().scene_name)
	

# todo: make this async
func load_new_scene(new_scene_name: String):
	if not $SceneChangeTimer.is_stopped():
		return
	
	player.set_frozen(true)
	next_scene_path = SCENE_PATH+new_scene_name+".tscn"
	ResourceLoader.load_threaded_request(next_scene_path)
	
	var current_cell = dream_grid.get_current_cell()
	
	var transition_obj : transition = canvas_layer.get_node("transition")
	transition_obj.transition(current_cell.is_nightmare)
	await transition_obj.transition_mid_point

	var new_scene_resource = ResourceLoader.load_threaded_get(next_scene_path)
	var new_scene = new_scene_resource.instantiate()
	
	# Remove old scene
	if current_scene_node:
		current_scene_node.queue_free()
		current_scene_node = null
	
	add_child(new_scene)
	current_scene_node = new_scene
	var new_spawn = current_scene_node.get_node("PlayerSpawn")
	player.set_spawn_position(new_spawn.position, new_spawn.rotation)
	
	canvas_layer.get_node("NightmareOverlay").visible = current_cell.is_nightmare
	
	var dream_grid_representation = current_scene_node.get_node("DreamGridRepresentation")
	if (dream_grid_representation):
		dream_grid_representation.create_representation(dream_grid)
		
	transition_obj.finish_transition()
	await transition_obj.transition_end_point
	player.set_frozen(false)
	

func set_transition_alpha(alpha : float):
	var transition_obj : transition = canvas_layer.get_node("transition")
	transition_obj.set_progress(alpha)

func does_key_exist(key : String) -> bool:
	var current_cell : DreamCell = dream_grid.get_current_cell()
	return current_cell.dream_keys.has(key) or dream_grid.dream_keys.has(key)

func is_direction_allowed(direction : Vector2i) -> bool:
	var current_cell : DreamCell = get_current_cell()
	if direction == -Vector2i.UP:
		return current_cell.allow_up
	if direction == Vector2i.RIGHT:
		return current_cell.allow_right
	if direction == -Vector2i.DOWN:
		return current_cell.allow_down
	if direction == Vector2i.LEFT:
		return current_cell.allow_left
	return true
	
func get_dream_grid() -> DreamGrid:
	return dream_grid

func get_current_cell() -> DreamCell:
	return dream_grid.get_current_cell()
