extends SubMenu


func _on_print_lobby_data_pressed() -> void:
	(Main.mode as P2PHostMode).lobby_database.output_data()


func _on_host_pressed() -> void:
	pass # Replace with function body.


func _on_back_pressed() -> void:
	Main.mode.close()
	holder.open_menu()
