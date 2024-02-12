extends Node3D

@export var item_name : String

func _ready():
	if PlayerSettings.found_items.has(item_name):
		queue_free()

func _on_interaction():
	GameManager.player.add_found_item(item_name, true)
	GameManager.hide_interact_text()
	queue_free()
