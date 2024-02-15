class_name Inventory extends Control

var is_open = false
@onready var description_node = $VBoxContainer/DescriptionFrame/MarginContainer/VBoxContainer

func _input(event):
	if event.is_action_pressed("Inventory"):
		toggle_menu()

func _ready():
	$ModulateFade.reset(false)

func toggle_menu():
	if is_open:
		$ModulateFade.fade_out()
		await $ModulateFade.on_finished
		close_menu()
		GameManager.set_game_focus(true)
	else:
		set_menu()
		refresh_visibilities()
		GameManager.set_game_focus(false)
		$ModulateFade.fade_in()
		await $ModulateFade.on_finished

func close_menu():
	hide()
	is_open = false
	GameManager.inventory_open = false

func set_menu ():
	is_open = true
	GameManager.inventory_open = true
	show()

func _on_start_pressed():
	
	$ModulateFade.fade_out()
	await $ModulateFade.on_finished
	close_menu()
	
	GameManager.start_game()

func _on_exit_pressed():
	GameManager.exit_game()

func _on_resume_pressed():
	toggle_menu()

func refresh_visibilities():
	var has_items = false
	for child in $VBoxContainer/VBoxContainer/Items.get_children():
		if child is InventoryIcon:
			var vis = child.refresh_visibility()
			has_items = vis or has_items
	
	var has_dreams = false
	for child in $VBoxContainer/VBoxContainer/Dreams.get_children():
		if child is DreamIcon:
			var vis = child.refresh_visibility()
			has_dreams = vis or has_dreams
	
	if not has_items:
		$VBoxContainer/VBoxContainer/Items/Nothing.show()
	else:
		$VBoxContainer/VBoxContainer/Items/Nothing.hide()
	
	if not has_dreams:
		$VBoxContainer/VBoxContainer/Dreams/Nothing.show()
	else:
		$VBoxContainer/VBoxContainer/Dreams/Nothing.hide()
	
	clear_focus()

func set_focus(item):
	if item is InventoryIcon:
		description_node.get_node("Item Name").text = item.item_name
		description_node.get_node("Description").text = item.description
		if item.equippable:
			description_node.get_node("Attributes").show()
		else:
			description_node.get_node("Attributes").hide()
	elif item is DreamIcon:
		description_node.get_node("Item Name").text = item.dream_name
		description_node.get_node("Description").text = item.description
		description_node.get_node("Attributes").hide()
	
	$VBoxContainer/DescriptionFrame.modulate.a = 1.0
	
func clear_focus():
	description_node.get_node("Item Name").text = ""
	description_node.get_node("Description").text = ""
	description_node.get_node("Attributes").hide()
	$VBoxContainer/DescriptionFrame.modulate.a = 0.6
