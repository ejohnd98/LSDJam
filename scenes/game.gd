extends Node3D

const SCENE_PATH = "res://scenes/scenes/"

@export var default_scene: String = "default_scene"

var current_scene_node = null
var next_scene_path = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	load_new_scene(default_scene)

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
	$Player.set_frozen(false)
