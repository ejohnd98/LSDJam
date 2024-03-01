@tool
class_name DreamCell

extends CanvasItem

@export var scene_name: String = "default_scene"

@export var is_nightmare = false
@export var is_dream_transition = false
@export var is_goal = false
@export var is_start = false

#TODO: set this false once key has been picked up
@export var has_key = false
@export var has_multiple_spawns = false
@export var has_position_spawns = false

@export_group("Allowed Directions")
@export var allow_up = false
@export var allow_right = false
@export var allow_down = false
@export var allow_left = false

@export_group("Keys")
@export var dream_keys: Array[String] = []

var grid_position : Vector2i

func _process(delta):
	if Engine.is_editor_hint():
		UpdateTexture()
		if dream_keys.size() > 0:
			set_self_modulate(Color.AQUA)
			self_modulate.a = 0.5
		else:
			set_self_modulate(Color.WHITE)
			self_modulate.a = 0.5

func _ready():
	is_dream_transition = is_nightmare
	UpdateTexture(is_start)

@export var key_key : String = ""
func ShowKey() -> bool:
	return has_key and not GameManager.does_key_exist(key_key)

func UpdateTexture(showPlayer: bool = false):
	if showPlayer:
		$Overlay.texture = load("res://textures/DreamGrid/you_icon.png")
		$Overlay.visible = true
	elif is_goal:
		$Overlay.texture = load("res://textures/DreamGrid/goal_icon.png")
		$Overlay.visible = true
	elif is_start:
		$Overlay.texture = load("res://textures/DreamGrid/starting_icon.png")
		$Overlay.visible = true
	elif is_nightmare or is_dream_transition:
		$Overlay.texture = load("res://textures/DreamGrid/skull_icon.png")
		$Overlay.visible = true
	elif has_key:
		$Overlay.texture = load("res://textures/DreamGrid/key_icon.png")
		$Overlay.visible = true
	else:
		$Overlay.visible = false
	
	var allowed_directions = [allow_up, allow_right, allow_down, allow_left]
	var direction_images = [$Up, $Right, $Down, $Left]
	
	for i in 4:
		if allowed_directions[i] and not is_dream_transition and not is_goal:
			direction_images[i].show()
		else:
			direction_images[i].hide()
