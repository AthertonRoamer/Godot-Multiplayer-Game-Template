extends SubMenu

func opened() -> void:
	$VBoxContainer/LobbyDisplay.lobby = Main.mode.lobby
	Network.server_disconnected.connect(_on_server_disconnected)
	
	
func _on_server_disconnected() -> void:
	_on_back_pressed()


func _on_back_pressed() -> void:
	(Main.mode as ClientMode).close()
	Network.server_disconnected.disconnect(_on_server_disconnected)
	await get_tree().process_frame
	(get_parent() as SubMenuHolder).open_menu("client_menu")
