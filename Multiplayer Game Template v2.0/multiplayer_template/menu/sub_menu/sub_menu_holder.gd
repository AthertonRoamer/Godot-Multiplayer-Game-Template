class_name SubMenuHolder
extends Control

var menus : Array[SubMenu]
var active_menu : SubMenu


func open_menu(menu_name : String = "default") -> void:
	for menu in menus:
		if is_instance_valid(menu) and menu != active_menu:
			menu = (menu as SubMenu)
			if menu.menu_name == menu_name:
				if is_instance_valid(active_menu):
					active_menu.set_open(false)
				menu.set_open(true)
				active_menu = menu
				break
	
	
func load_sub_menus() -> void:
	for child in get_children():
		if child is SubMenu:
			menus.append(child)
	
	
func initialize_sub_menus() -> void:
	for sub_menu in menus:
		sub_menu.holder = self
		sub_menu.set_open(false)
		
		
func _ready() -> void:
	load_sub_menus()
	initialize_sub_menus()
	open_menu()
