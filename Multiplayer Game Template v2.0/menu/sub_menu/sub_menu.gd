class_name SubMenu
extends Control

var holder : SubMenuHolder
@export var menu_name : String = "default"

func set_open(b : bool) -> void:
	visible = b
