class_name MainMenu extends Control

enum MenuType {MAIN_MENU, PAUSE_MENU}

var current_menu : MenuType = MenuType.MAIN_MENU
var is_open = false
var is_paused = false

var settings_open = false
var controls_open = false
var credits_open = false

var menu_disabled = false

signal on_menu_type_changed (menu_type : MenuType)

func _input(event):
	if menu_disabled:
		return
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
	$ModulateFade.reset(true)
	GameManager.black_fade.reset(true)
	GameManager.intro_fade.reset(false)
	process_mode = Node.PROCESS_MODE_ALWAYS
	PlayerSettings.load_settings()
	PlayerSettings.refresh_fullscreen()
	set_menu(MenuType.MAIN_MENU)
	$ColorRect.use_distortion = true
	GameManager.black_fade.fade_out()

func set_paused(pause_state):
	get_tree().paused = pause_state
	is_paused = pause_state

func toggle_pause_menu():
	if menu_disabled:
		return
	if is_open:
		$ModulateFade.fade_out()
		$ColorRect.use_distortion = false
		await $ModulateFade.on_finished
		set_paused(false)
		close_menu()
		GameManager.set_game_focus(not GameManager.inventory_open)
	else:
		set_menu(MenuType.PAUSE_MENU)
		GameManager.set_game_focus(false)
		set_paused(true)
		$ModulateFade.fade_in()
		$ColorRect.use_distortion = true
		await $ModulateFade.on_finished

func toggle_settings_menu():
	if menu_disabled:
		return
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
		$"Settings/Reset Progress".show()
		$"Settings/Reset Progress2".hide()
		
		$Settings/ModulateFade.fade_out()
		await $Settings/ModulateFade.on_finished
		$Settings.hide()
		
		$Settings.SaveSettings()
		$MainMenuButtons/ModulateFade.reset(false)
		$MainMenuButtons.show()
		$MainMenuButtons/ModulateFade.fade_in()
		await $MainMenuButtons/ModulateFade.on_finished

func toggle_credits_menu():
	if menu_disabled:
		return
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
	if menu_disabled:
		return
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
	if menu_disabled:
		return
	menu_disabled = true
	
	GameManager.black_fade.reset(false)
	$ColorRect.use_distortion = false
	
	GameManager.black_fade.fade_in()
	await GameManager.black_fade.on_finished
	
	if not OS.has_feature("editor"):
		GameManager.intro_fade.fade_in()
		await GameManager.intro_fade.on_finished
	
	close_menu()
	$MainMenuBG.hide()
	$ModulateFade.reset(false)
	
	if not OS.has_feature("editor"):
		await get_tree().create_timer(5.0).timeout
	
	GameManager.start_game()
	$MainMenuBG.hide()
	$MainMenuBG2.hide()
	$MainMenuBG3.hide()
	
	
	
	await GameManager.on_dream_started
	$MenuMusic.stop()
	menu_disabled = false
	
	if not OS.has_feature("editor"):
		GameManager.intro_fade.fade_out()
	GameManager.black_fade.fade_out()

func _on_exit_pressed():
	if menu_disabled:
		return
	GameManager.exit_game()

func _on_resume_pressed():
	if menu_disabled:
		return
	toggle_pause_menu()

func _on_main_menu_pressed():
	pass # Replace with function body.

func _on_settings_pressed():
	if menu_disabled:
		return
	toggle_settings_menu()

func _on_controls_pressed():
	if menu_disabled:
		return
	toggle_controls_menu()

func _on_credits_pressed():
	if menu_disabled:
		return
	toggle_credits_menu()


func _on_reset_progress_pressed():
	if menu_disabled:
		return
	$"Settings/Reset Progress".hide()
	$"Settings/Reset Progress2".show()

func _on_reset_progress_2_pressed():
	if menu_disabled:
		return
	PlayerSettings.clear_progress()
	GameManager.exit_game()
