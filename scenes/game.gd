extends Node3D

const SCENE_PATH = "res://scenes/scenes/"

@export var default_scene: String = "default_scene"

@export var dreams: Array[PackedScene] = []

var current_dream : Control = null
var dream_index = -1

@onready var dream_grid : DreamGrid = $"../../CanvasLayer/DreamGrid"

var current_scene_node = null
var next_scene_path = ""

func _ready():
	advance_dream()
	
func move_in_direction(direction: Vector2i):
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
		$"../../CanvasLayer/WinScreen".visible = true
		$Player.set_frozen(true)
		return
	dream_index += 1
	
	#remove old dream grid
	if dream_grid:
		dream_grid.queue_free()
		dream_grid = null
	
	#add new dream grid
	var new_dream = dreams[dream_index].instantiate()
	$"../../CanvasLayer".add_child(new_dream)
	dream_grid = new_dream
	dream_grid.initialize_grid()
	
	#load starting scene
	load_new_scene(dream_grid.get_start_cell().scene_name)
	

# todo: make this async
func load_new_scene(new_scene_name: String):
	if not $SceneChangeTimer.is_stopped():
		return
	
	$Player.set_frozen(true)
	next_scene_path = SCENE_PATH+new_scene_name+".tscn"
	ResourceLoader.load_threaded_request(next_scene_path)
	
	$SceneChangeTimer.start()

func _on_scene_change_timer():
	var new_scene_resource = ResourceLoader.load_threaded_get(next_scene_path)
	var new_scene = new_scene_resource.instantiate()
	
	# Remove old scene
	if current_scene_node:
		current_scene_node.queue_free()
		current_scene_node = null
	
	add_child(new_scene)
	current_scene_node = new_scene
	var new_spawn = current_scene_node.get_node("PlayerSpawn")
	$Player.set_spawn_position(new_spawn.position, new_spawn.rotation)
	
	var current_cell = dream_grid.get_current_cell()
	$"../../CanvasLayer/NightmareOverlay".visible = current_cell.is_nightmare
	
	$Player.set_frozen(false)
