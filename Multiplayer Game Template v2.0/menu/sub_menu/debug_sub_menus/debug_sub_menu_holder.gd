class_name DebugSubMenuHolder
extends SubMenuHolder

enum menu_options {DEFAULT, SERVER, CLIENT}

@export var default_menu : DebugSubMenu
@export var server_menu : DebugSubMenu
@export var client_menu : DebugSubMenu

func _ready():
	menus = [default_menu, server_menu, client_menu]
	initialize_sub_menus()
	open_menu(menu_options.DEFAULT)
