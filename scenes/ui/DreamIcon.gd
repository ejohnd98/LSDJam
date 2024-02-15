class_name DreamIcon extends TextureRect

@export var required_key : String

@export var dream_name : String
@export var description : String

@onready var inventory : Inventory = $"../../../.."

func _ready():
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_leave)
	modulate.a = 0.6

func refresh_visibility() -> bool:
	if PlayerSettings.has_completed_dream(required_key):
		show()
		return true
	else:
		hide()
		return false

func on_mouse_enter():
	modulate.a = 1.0
	inventory.set_focus(self)

func on_mouse_leave():
	modulate.a = 0.6
	inventory.clear_focus()
