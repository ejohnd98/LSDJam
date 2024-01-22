extends Control

func _ready():
	#debug
	#_on_start_pressed()
	pass

func _on_start_pressed():
	hide()
	
	await get_tree().create_timer(1.0).timeout
	
	GameManager.start_game()

func _on_exit_pressed():
	GameManager.exit_game()
