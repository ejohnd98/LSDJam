class_name DreamCell

extends Node

@export var scene_name: String = "default_scene"

@export var is_nightmare = false
@export var is_goal = false
@export var is_start = false

@export var dream_info = {}
var grid_position : Vector2i

func _ready():
	UpdateTexture(is_start)

func UpdateTexture(showPlayer: bool = false):
	if showPlayer:
		$Overlay.texture = load("res://textures/DreamGrid/you_icon.png")
		$Overlay.visible = true
	elif is_goal:
		$Overlay.texture = load("res://textures/DreamGrid/goal_icon.png")
		$Overlay.visible = true
	elif is_nightmare:
		$Overlay.texture = load("res://textures/DreamGrid/skull_icon.png")
		$Overlay.visible = true
	else:
		$Overlay.visible = false
		
