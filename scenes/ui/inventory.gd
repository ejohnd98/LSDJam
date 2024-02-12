class_name Inventory extends Control

var is_open = false

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
