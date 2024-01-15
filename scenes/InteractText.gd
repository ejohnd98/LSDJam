extends Control

func _ready():
	hide_text()

func set_text(new_text : String):
	$Label.text = new_text

func hide_text():
	$Label.text = ""
