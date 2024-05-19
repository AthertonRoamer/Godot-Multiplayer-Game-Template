class_name SubMenu
extends Control

var holder : SubMenuHolder
var open : bool = false
@export var menu_name : String = "default"

func set_open(b : bool) -> void:
	visible = b
	if open != b:
		if b:
			opened()
		else:
			closed()
	
	
func opened() -> void:
	pass
	
	
func closed() -> void:
	pass
