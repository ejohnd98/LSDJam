extends Node

var mouse_sensitivity = 0.8
var overall_volume = 0.8

#setters
func set_overall_volume(new_volume : float):
	overall_volume = new_volume
	var volume_db = -80.0 + (80.0 * (1.0 - pow(1 - new_volume, 5)))
	print("volume: " + str(volume_db))
	AudioServer.set_bus_volume_db(0, volume_db)

func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("Player", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("Player", "overall_volume", overall_volume)
	
	config.save("user://settings.cfg")

func load_settings():
	
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err != OK:
		return
	
	for section in config.get_sections():
		if config.has_section_key(section, "mouse_sensitivity"):
			mouse_sensitivity = config.get_value(section, "mouse_sensitivity")
		if config.has_section_key(section, "overall_volume"):
			set_overall_volume(config.get_value(section, "overall_volume"))
