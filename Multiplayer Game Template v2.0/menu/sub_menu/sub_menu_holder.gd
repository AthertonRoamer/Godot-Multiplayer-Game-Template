class_name SubMenuHolder
extends Control

var menus : Array[SubMenu]
var active_menu : SubMenu

func open_menu(menu_index : int) -> void:
	if menus[menu_index] != active_menu:
		if is_instance_valid(active_menu):
			active_menu.set_open(false)
		menus[menu_index].set_open(true)
		active_menu = menus[menu_index]
	
	
func initialize_sub_menus() -> void:
	for sub_menu in menus:
		sub_menu.holder = self
		sub_menu.set_open(false)
		
		
func _ready() -> void:
	initialize_sub_menus()
