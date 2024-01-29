extends Control

@export var on_main_menu = true
@export var on_pause_menu = true

func _ready():
	$"../..".on_menu_type_changed.connect(on_menu_changed)

func on_menu_changed(menu : MainMenu.MenuType):
	if on_main_menu and menu == MainMenu.MenuType.MAIN_MENU:
		show()
	elif on_pause_menu and menu == MainMenu.MenuType.PAUSE_MENU:
		show()
	else:
		hide()
