class_name prompt_controller extends Control

@export var label_settings : LabelSettings

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_control_info()

func add_prompt(text : String):
	var new_prompt : Label = Label.new()
	new_prompt.label_settings = label_settings
	new_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	new_prompt.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	new_prompt.text = text
	
	$VBoxContainer.add_child(new_prompt)
	

func clear_control_info():
	for child in $VBoxContainer.get_children():
		child.queue_free()
