extends SubMenu

func opened() -> void:
	super()
	(Main.mode as P2PHostMode).lobby.game_began.connect(Main.main.active_scene._on_game_started)
	(Main.mode as P2PHostMode).lobby.game_ended.connect(Main.main.active_scene._on_game_ended)
	(Main.main.mode as P2PHostMode).my_member_data.name = $VBoxContainer/ManualNameInput/LineEdit.text
	

func _on_print_lobby_data_pressed() -> void:
	(Main.mode as P2PHostMode).lobby_database.output_data()


func _on_host_pressed() -> void:
	(Main.main.mode as P2PHostMode).host()
	
	
func _on_host_lan_pressed() -> void:
	(Main.main.mode as P2PHostMode).host_with_lan()


func _on_back_pressed() -> void:
	Main.mode.close()
	holder.open_menu()


func _on_line_edit_text_changed(new_text: String) -> void:
	(Main.main.mode as P2PHostMode).my_member_data.name = new_text


func _on_start_pressed() -> void:
	(Main.mode.lobby as Lobby).trigger_request_begin_game()
