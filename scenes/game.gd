extends Node3D

@export var default_scene: PackedScene

var current_scene_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	load_new_scene(default_scene)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# todo: make this async
func load_new_scene(new_scene_path: PackedScene):
	$Player.set_frozen(true)
	
	# Remove old scene
	if current_scene_node:
		current_scene_node.queue_free()
	
	# Load new scene
	current_scene_node = new_scene_path.instantiate()
	add_child(current_scene_node)
	
	$Player.set_frozen(false)
