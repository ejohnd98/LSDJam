extends Control

func RefreshFromSavedSettings():
	PlayerSettings.load_settings()
	$"Mouse Sensitivity/MouseSensitivity".value = PlayerSettings.mouse_sensitivity
	$Volume/Volume.value = PlayerSettings.overall_volume
	$"Max Fps/LineEdit".text = str(PlayerSettings.max_fps)

func SaveSettings():
	PlayerSettings.mouse_sensitivity = $"Mouse Sensitivity/MouseSensitivity".value
	PlayerSettings.max_fps = int($"Max Fps/LineEdit".text)
	PlayerSettings.save_settings()

func _process(delta):
	if is_visible_in_tree():
		PlayerSettings.set_overall_volume($Volume/Volume.value)
