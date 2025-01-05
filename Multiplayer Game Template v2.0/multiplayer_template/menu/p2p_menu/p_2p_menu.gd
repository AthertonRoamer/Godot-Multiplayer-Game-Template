extends Control

@export var sub_menu_holder : SubMenuHolder


func _on_host_pressed() -> void:
	Main.open_mode(P2PHostMode.new())


func _on_join_pressed() -> void:
	pass # Replace with function body.
