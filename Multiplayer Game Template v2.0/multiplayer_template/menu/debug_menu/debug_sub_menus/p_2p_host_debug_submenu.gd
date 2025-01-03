extends SubMenu


func _on_print_lobby_data_pressed() -> void:
	(Main.mode as P2PHostMode).lobby_database.output_data()


func _on_host_pressed() -> void:
	(Main.main.mode as P2PHostMode).host()


func _on_back_pressed() -> void:
	Main.mode.close()
	holder.open_menu()


func _on_line_edit_text_changed(new_text: String) -> void:
	(Main.main.mode as P2PHostMode).my_member_data.name = new_text
