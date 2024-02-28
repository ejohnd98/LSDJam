class_name MainMenu extends Control

enum MenuType {MAIN_MENU, PAUSE_MENU}

var current_menu : MenuType = MenuType.MAIN_MENU
var is_open = false
var is_paused = false

var settings_open = false
var controls_open = false
var credits_open = false

signal on_menu_type_changed (menu_type : MenuType)

func _input(event):
	if event.is_action_pressed("Escape"):
		if settings_open:
			toggle_settings_menu()
		elif credits_open:
			toggle_credits_menu()
		elif controls_open:
			toggle_controls_menu()
		elif is_paused or GameManager.can_pause:
			toggle_pause_menu()

func _ready():
	$ModulateFade.reset(false)
	process_mode = Node.PROCESS_MODE_ALWAYS
	PlayerSettings.load_settings()
	set_menu(MenuType.MAIN_MENU)
	$ModulateFade.fade_in()

func set_paused(pause_state):
	get_tree().paused = pause_state
	is_paused = pause_state

func toggle_pause_menu():
	if is_open:
		$ModulateFade.fade_out()
		await $ModulateFade.on_finished
		set_paused(false)
		close_menu()
		GameManager.set_game_focus(not GameManager.inventory_open)
	else:
		set_menu(MenuType.PAUSE_MENU)
		GameManager.set_game_focus(false)
		set_paused(true)
		$ModulateFade.fade_in()
		await $ModulateFade.on_finished

func toggle_settings_menu():
	settings_open = not settings_open
	
	if settings_open:
		$MainMenuButtons/ModulateFade.fade_out()
		await $MainMenuButtons/ModulateFade.on_finished
		$MainMenuButtons.hide()
		
		$Settings/ModulateFade.reset(false)
		$Settings.RefreshFromSavedSettings()
		$Settings.show()
		$Settings/ModulateFade.fade_in()
		await $Settings/ModulateFade.on_finished
		
	else:
		$Settings/ModulateFade.fade_out()
		await $Settings/ModulateFade.on_finished
		$Settings.hide()
		
		$Settings.SaveSettings()
		$MainMenuButtons/ModulateFade.reset(false)
		$MainMenuButtons.show()
		$MainMenuButtons/ModulateFade.fade_in()
		await $MainMenuButtons/ModulateFade.on_finished

func toggle_credits_menu():
	credits_open = not credits_open
	
	if credits_open:
		$MainMenuButtons/ModulateFade.fade_out()
		await $MainMenuButtons/ModulateFade.on_finished
		$MainMenuButtons.hide()
		
		$Credits/ModulateFade.reset(false)
		$Credits.show()
		$Credits/ModulateFade.fade_in()
		await $Credits/ModulateFade.on_finished
		
	else:
		$Credits/ModulateFade.fade_out()
		await $Credits/ModulateFade.on_finished
		$Credits.hide()

		$MainMenuButtons/ModulateFade.reset(false)
		$MainMenuButtons.show()
		$MainMenuButtons/ModulateFade.fade_in()
		await $MainMenuButtons/ModulateFade.on_finished

func toggle_controls_menu():
	controls_open = not controls_open
	
	if controls_open:
		$MainMenuButtons/ModulateFade.fade_out()
		await $MainMenuButtons/ModulateFade.on_finished
		$MainMenuButtons.hide()
		
		$Controls/ModulateFade.reset(false)
		$Controls.show()
		$Controls/ModulateFade.fade_in()
		await $Controls/ModulateFade.on_finished
		
	else:
		$Controls/ModulateFade.fade_out()
		await $Controls/ModulateFade.on_finished
		$Controls.hide()

		$MainMenuButtons/ModulateFade.reset(false)
		$MainMenuButtons.show()
		$MainMenuButtons/ModulateFade.fade_in()
		await $MainMenuButtons/ModulateFade.on_finished

func close_menu():
	hide()
	is_open = false

func set_menu (menu : MenuType):
	current_menu = menu
	is_open = true
	on_menu_type_changed.emit(menu)
	
	if menu == MenuType.MAIN_MENU:
		$MenuMusic.play()
	else:
		$MenuMusic.stop()
	
	show()

func _on_start_pressed():
	
	$ModulateFade.fade_out()
	await $ModulateFade.on_finished
	close_menu()
	$MenuMusic.stop()
	
	GameManager.start_game()

func _on_exit_pressed():
	GameManager.exit_game()

func _on_resume_pressed():
	toggle_pause_menu()

func _on_main_menu_pressed():
	pass # Replace with function body.

func _on_settings_pressed():
	toggle_settings_menu()

func _on_controls_pressed():
	toggle_controls_menu()

func _on_credits_pressed():
	toggle_credits_menu()
