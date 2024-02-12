extends Node3D

@export var item_name : String
@export var pickup_prompt : String = "pick up"

func _ready():
	if PlayerSettings.found_items.has(item_name):
		queue_free()
	else:
		$Interaction.interact_prompt = pickup_prompt

func _on_interaction():
	GameManager.player.add_found_item(item_name, true)
	GameManager.hide_interact_text()
	queue_free()
