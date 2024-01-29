class_name PlayerItem extends Node3D

signal on_equip
signal on_unequip

@export var keep_between_dreams = false
@export var destroy_on_start_if_already_equipped = true
@export var item_key : String

func _ready():
	if destroy_on_start_if_already_equipped and GameManager.is_item_equipped(item_key):
		queue_free()

func _on_interactable_object_interact():
	GameManager.player.equip_item(self)

func _on_on_equip():
	$InteractableObject/CollisionShape3D.disabled = true

func _on_on_unequip():
	$InteractableObject/CollisionShape3D.disabled = false
