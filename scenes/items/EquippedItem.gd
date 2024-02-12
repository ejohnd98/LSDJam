class_name EquippedItem extends Node3D

signal on_equipped
signal on_unequipped

@export var item_name : String

func equip_item():
	on_equipped.emit()

func unequip_item():
	on_unequipped.emit()
