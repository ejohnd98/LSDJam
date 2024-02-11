extends Control

func _ready():
	hide_text()

func set_text(new_text : String, use_distortion : bool = false):
	$Label.text = new_text
	
	if use_distortion:
		$DistortedText.text = new_text
		$ColorRect.show()
	else:
		$DistortedText.text = ""
		$ColorRect.hide()

func hide_text():
	set_text("")
