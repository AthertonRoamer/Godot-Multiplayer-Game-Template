extends SubMenu

var game_id : String = ""
func opened() -> void:
	$VBoxContainer/GameIDDisplay.visible = Main.main.configuration.lobby_args.has("--mode noray_lobby")
	(Main.mode as P2PHostMode).lobby_database.data_changed.connect(_on_lobby_data_updated)
	$VBoxContainer/LobbyDisplay.lobby = Main.mode.lobby
	Main.output("Opening host menu")
	

func _on_back_pressed() -> void:
	Main.main.mode.close()
	(get_parent() as SubMenuHolder).open_menu()
	
	
func _on_lobby_data_updated() -> void:
	game_id =  (Main.mode as P2PHostMode).lobby.stats.game_id
	$VBoxContainer/GameIDDisplay/Label.text = "Game ID: " + game_id


func _on_copy_game_id_pressed() -> void:
	DisplayServer.clipboard_set(game_id)


func _on_start_pressed() -> void:
	(Main.mode.lobby as Lobby).trigger_request_begin_game()
