extends Node

var mouse_sensitivity = 0.8
var overall_volume = 0.8

var completed_dreams : PackedStringArray
var current_dream_array = null

var found_items : PackedStringArray = [""]

var misc_items : PackedStringArray = []

@export var save_completed_dreams = false

#setters
func set_overall_volume(new_volume : float):
	overall_volume = new_volume
	var volume_db = -80.0 + (80.0 * (1.0 - pow(1 - new_volume, 5)))
	AudioServer.set_bus_volume_db(0, volume_db)

func add_item(item_name : String):
	misc_items.append(item_name)
	PlayerSettings.save_settings()
	GameManager.canvas_layer.get_node("DebugDreamText/Label").text = "Dreams:\n" + "\n".join(completed_dreams) + "\nItems:\n" + "\n".join(misc_items)

func add_completed_dream(dream_name : String):
	completed_dreams.append(dream_name)
	PlayerSettings.save_settings()
	GameManager.canvas_layer.get_node("DebugDreamText/Label").text = "Dreams:\n" + "\n".join(completed_dreams) + "\nItems:\n" + "\n".join(misc_items)

func has_completed_dream(dream_name : String) -> bool:
	return completed_dreams.has(dream_name)

func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("Player", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("Player", "overall_volume", overall_volume)
	if save_completed_dreams:
		config.set_value("Player", "completed_dreams", completed_dreams)
		config.set_value("Player", "current_dream_array", GameManager.dreams)
		config.set_value("Player", "found_items", found_items)
		config.set_value("Player", "misc_items", misc_items)
	else:
		config.set_value("Player", "completed_dreams", null)
		config.set_value("Player", "current_dream_array", null)
		config.set_value("Player", "found_items", null)
		config.set_value("Player", "misc_items", null)
	
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
		if save_completed_dreams:
			if config.has_section_key(section, "completed_dreams"):
				completed_dreams = config.get_value(section, "completed_dreams")
			if config.has_section_key(section, "current_dream_array"):
				current_dream_array = config.get_value(section, "current_dream_array")
			if config.has_section_key(section, "found_items"):
				found_items = config.get_value(section, "found_items")
			if config.has_section_key(section, "misc_items"):
				misc_items = config.get_value(section, "misc_items")
		else:
			completed_dreams.clear()
			current_dream_array = null
			
	
	#debug:
	GameManager.canvas_layer.get_node("DebugDreamText/Label").text = "Dreams:\n" + "\n".join(completed_dreams) + "\nItems:\n" + "\n".join(misc_items)
