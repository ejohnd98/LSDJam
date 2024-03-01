extends Control

func RefreshFromSavedSettings():
	PlayerSettings.load_settings()
	$"Mouse Sensitivity/MouseSensitivity".value = PlayerSettings.mouse_sensitivity
	$Volume/Volume.value = PlayerSettings.overall_volume
	$"Max Fps/LineEdit".text = str(PlayerSettings.max_fps)
	
	if not PlayerSettings.is_fullscreen:
		$"Window Mode/MenuBar".get_child(0).name = "Windowed"
	else:
		$"Window Mode/MenuBar".get_child(0).name = "Fullscreen"
	$"Window Mode/MenuBar".hide()
	$"Window Mode/MenuBar".show()
	
	$"Auto Run/CheckBox".set_pressed_no_signal(PlayerSettings.auto_run)
	

func SaveSettings():
	PlayerSettings.mouse_sensitivity = $"Mouse Sensitivity/MouseSensitivity".value
	PlayerSettings.max_fps = int($"Max Fps/LineEdit".text)
	PlayerSettings.save_settings()

func _process(delta):
	if is_visible_in_tree():
		PlayerSettings.set_overall_volume($Volume/Volume.value)


func _on_popup_menu_index_pressed(index):
	if index == 0:
		PlayerSettings.is_fullscreen = false
		$"Window Mode/MenuBar".get_child(0).name = "Windowed"
	else:
		PlayerSettings.is_fullscreen = true
		$"Window Mode/MenuBar".get_child(0).name = "Fullscreen"
	PlayerSettings.refresh_fullscreen()
	$"Window Mode/MenuBar".get_child(0).set_focused_item(index)
	$"Window Mode/MenuBar".hide()
	$"Window Mode/MenuBar".show()
	PlayerSettings.save_settings()



func _on_check_box_toggled(toggled_on):
	PlayerSettings.auto_run = toggled_on

func _on_auto_run_pressed():
	$"Auto Run/CheckBox".button_pressed = not $"Auto Run/CheckBox".button_pressed
