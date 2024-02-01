class_name game_manager
extends Node3D

const SCENE_PATH = "res://scenes/scenes/"

@export var default_scene: String = "default_scene"

@export var dreams: Array[PackedScene] = []

@export var nightmares: Array[PackedScene] = []

@export var transitions: Array[PackedScene] = []

@export var dream_transition: PackedScene #goal transition

var current_dream : Control = null
var dream_index = -1

#TODO: make these more random than just a linear wrap around
var nightmare_index = -1
var transition_index = -1

@onready var dream_grid : DreamGrid = get_tree().get_root().get_node("SubViewportContainer/CanvasLayer/DreamGrid")
@onready var canvas_layer = get_tree().get_root().get_node("SubViewportContainer/SubViewport/CanvasLayer")
@onready var player : LSDPlayer = get_tree().get_root().get_node("SubViewportContainer/SubViewport/Player")
@onready var main_menu : MainMenu = get_tree().get_root().get_node("SubViewportContainer/SubViewport/CanvasLayer/MainMenu")

var current_scene_node = null
var next_scene_path = ""
var can_pause = false

var rng = RandomNumberGenerator.new()

var nightmare_recovery_speed = 0.01
var nightmare_progress = 0.0
var in_nightmare = false

var in_transition_dream = false

static func get_game(tree_node : SceneTree) -> game_manager:
	return tree_node.get_root().get_node("SubViewportContainer/SubViewport/Game")

func _unhandled_input(event):
	if event.is_action_pressed("DebugEsc"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			set_cursor_state(false)
		else:
			set_cursor_state(true)
	if event.is_action_pressed("DebugNightmare"):
		pick_nightmare()

func set_cursor_state(is_captured : bool):
	if is_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_game_focus(on_player : bool):
	set_cursor_state(on_player)

func _ready():
	set_cursor_state(false)
	#TODO: separate game and menu UI into two different scenes and hide/show those
	canvas_layer.get_node("UIParent/Compass").hide()
	canvas_layer.get_node("Crosshair").hide()
	canvas_layer.get_node("NightmareBar").hide()
	player.set_frozen(true)

func start_game():
	set_cursor_state(true)
	player.interactable_changed.connect(on_interactable_change)
	canvas_layer.get_node("UIParent/Compass").show()
	canvas_layer.get_node("Crosshair").show()
	canvas_layer.get_node("NightmareBar").show()
	advance_dream()

func exit_game():
	get_tree().quit()

func on_entered_nightmare():
	canvas_layer.get_node("NightmareOverlay").show()
	canvas_layer.get_node("UIParent/Compass").hide()
	in_nightmare = true

func on_left_nightmare():
	canvas_layer.get_node("NightmareOverlay").hide()
	canvas_layer.get_node("UIParent/Compass").show()
	in_nightmare = false

func on_interactable_change(interactable):
	if interactable != null and interactable is click_interaction:
		set_interact_text(interactable.interact_prompt)
	else:
		hide_interact_text()
	
func move_in_direction(direction: Vector2i):
	if (not is_direction_allowed(direction)):
		return
		
	var current_cell = dream_grid.get_current_cell()
	
	if dream_index == -1: #in dream goal transition
		pick_random_dream(false)
		return
	
	dream_grid.move_in_direction(direction)
	var next_cell = dream_grid.get_current_cell()
	if next_cell.is_goal:
		if not dream_grid.is_nightmare:
			dreams.remove_at(dream_index)
			change_dreams(-1)
		else:
			pick_random_dream()
		return
	
	if next_cell.is_dream_transition: #spiral symbol on map
		pick_random_dream()
		return
		
	load_new_scene(dream_grid.get_scene_from_position(), direction)

func advance_dream():
	var next_index = dream_index
	if next_index + 1 == dreams.size():
		canvas_layer.get_node("WinScreen").visible = true
		player.set_frozen(true)
		return
	next_index += 1
	change_dreams(next_index)

func pick_random_dream(allow_transition_dreams : bool = true):
	var new_index = dream_index + rng.randi_range (1, dreams.size()-1) #pick random dream 	
	new_index = wrapi(new_index, 0, dreams.size())
	
	if (not in_transition_dream and allow_transition_dreams and randf() > 0.6):
		in_transition_dream = true
	else:
		in_transition_dream = false
	
	change_dreams(new_index)

func pick_nightmare():
	nightmare_index = wrapi(nightmare_index + 1, 0, nightmares.size())
	change_dreams(nightmare_index, true)

func get_next_transition_dream() -> PackedScene:
	transition_index = wrapi(transition_index + 1, 0, transitions.size())
	return transitions[transition_index]
	
 
func change_dreams(index : int, is_nightmare : bool = false):
	dream_index = index
	
	#remove old dream grid
	if dream_grid:
		dream_grid.queue_free()
		dream_grid = null
	
	var new_dream
	#add new dream grid
	if (dream_index == -1):
		new_dream = dream_transition.instantiate()
	elif is_nightmare and nightmares.size() > 0:
		new_dream = nightmares[dream_index].instantiate()
	elif in_transition_dream:
		new_dream = get_next_transition_dream().instantiate()
	elif dreams.size() > 0:
		new_dream = dreams[dream_index].instantiate()
	else:
		player.set_frozen(true)
		canvas_layer.get_node("WinScreen").visible = true
		return
		
	get_tree().get_root().get_node("SubViewportContainer/CanvasLayer").add_child(new_dream)
	dream_grid = new_dream
	dream_grid.initialize_grid()
	
	#load starting scene
	load_new_scene(dream_grid.get_start_cell().scene_name, Vector2i.UP, true)


func load_new_scene(new_scene_name: String, incoming_direction : Vector2i = Vector2i.UP, changing_dreams = false):
	if not $SceneChangeTimer.is_stopped():
		return
	
	player.set_frozen(true)
	can_pause = false
	canvas_layer.get_node("UIParent/Compass").set_frozen(true)
	
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
	
	# get player spawn position
	var new_spawn
	if current_cell.has_multiple_spawns:
		match incoming_direction:
			Vector2i.DOWN:
				new_spawn = current_scene_node.get_node("PlayerSpawnDown")
			Vector2i.RIGHT:
				new_spawn = current_scene_node.get_node("PlayerSpawnRight")
			Vector2i.UP:
				new_spawn = current_scene_node.get_node("PlayerSpawnUp")
			Vector2i.LEFT:
				new_spawn = current_scene_node.get_node("PlayerSpawnLeft")
		if new_spawn == null:
			push_warning("Could not get directional spawn point!")
			new_spawn = current_scene_node.get_node("PlayerSpawn")
				
	else:
		new_spawn = current_scene_node.get_node("PlayerSpawn")
		
	player.set_spawn_position(new_spawn.position, new_spawn.rotation)
	
	if dream_grid.is_nightmare and not in_nightmare:
		on_entered_nightmare()
	elif not dream_grid.is_nightmare and in_nightmare:
		on_left_nightmare()
	
	var dream_grid_representation = current_scene_node.get_node("DreamGridRepresentation")
	if (dream_grid_representation):
		dream_grid_representation.create_representation(dream_grid)
	
	#undo any camera stuff:
	if CameraManagerObject.override_active:
		CameraManagerObject.reset_camera()
	
	if changing_dreams:
		if player.equipped_item != null and not player.equipped_item.keep_between_dreams:
			player.unequip_item()
	
	transition_obj.finish_transition()
	GameManager.set_crosshair(true)
	await transition_obj.transition_end_point
	canvas_layer.get_node("LevelText").type_out_text(dream_grid.get_current_cell_name(not in_transition_dream))
	
	var footstep_override : AudioStreamPlayer = current_scene_node.get_node("FootstepOverride")
	if footstep_override != null:
		player.set_footstep_sounds(footstep_override.stream)
	else:
		player.reset_footstep_sounds()
	
	player.set_frozen(false)
	can_pause = true
	canvas_layer.get_node("UIParent/Compass").set_frozen(false)
	print("Player Grid Position: " + str(dream_grid.player_position))
	

func set_transition_alpha(alpha : float):
	var transition_obj : transition = canvas_layer.get_node("transition")
	transition_obj.set_progress(alpha)

func set_interact_text(interact_text : String):
	canvas_layer.get_node("InteractText").set_text(interact_text)

func hide_interact_text():
	canvas_layer.get_node("InteractText").hide_text()

func does_key_exist(key : String) -> bool:
	var current_cell : DreamCell = dream_grid.get_current_cell()
	return current_cell.dream_keys.has(key) or dream_grid.dream_keys.has(key)

func is_item_equipped(key : String) -> bool:
	if player.equipped_item != null:
		return key == player.equipped_item.item_key
	return false

func is_direction_allowed(direction : Vector2i) -> bool:
	var current_cell : DreamCell = get_current_cell()
	if direction == Vector2i.UP:
		return current_cell.allow_up
	if direction == Vector2i.RIGHT:
		return current_cell.allow_right
	if direction == Vector2i.DOWN:
		return current_cell.allow_down
	if direction == Vector2i.LEFT:
		return current_cell.allow_left
	return true
	
func get_dream_grid() -> DreamGrid:
	return dream_grid

func get_current_cell() -> DreamCell:
	return dream_grid.get_current_cell()

func set_crosshair(visible : bool):
	if visible:
		canvas_layer.get_node("Crosshair").show()
	else:
		canvas_layer.get_node("Crosshair").hide()

func _process(delta):
	adjust_nightmare_progress(-delta*nightmare_recovery_speed)

func adjust_nightmare_progress(delta : float):
	nightmare_progress += delta
	
	if nightmare_progress < 0:
		nightmare_progress = 0.0
	
	if nightmare_progress > 1.0:
		nightmare_progress = 0.0
		canvas_layer.get_node("NightmareBar/ProgressBar").value = nightmare_progress * 100
		pick_nightmare()
		return
	
	canvas_layer.get_node("NightmareBar/ProgressBar").value = nightmare_progress * 100
