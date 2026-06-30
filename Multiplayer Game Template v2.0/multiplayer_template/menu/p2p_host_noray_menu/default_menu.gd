extends SubMenu

func _on_host_pressed() -> void:
	if Main.main.configuration.lobby_args.has("--mode lobby"):
		Main.main.configuration.lobby_args.erase("--mode lobby")
		Main.main.configuration.lobby_args.append("--mode noray_lobby")
	Main.open_mode(P2PHostMode.new())
	(Main.main.mode as P2PHostMode).my_member_data.name = $VBoxContainer/NameInput.text
	(Main.main.mode as P2PHostMode).lobby_name = $VBoxContainer/NameInput.text
	(Main.mode as P2PHostMode).custom_noray_ip = $VBoxContainer/Advanced/LineEdit.text
	(Main.main.mode as P2PHostMode).host_with_lan()
	(get_parent() as SubMenuHolder).open_menu("host_menu")


func _on_host_lan_pressed() -> void:
	if Main.main.configuration.lobby_args.has("--mode noray_lobby"):
		Main.main.configuration.lobby_args.erase("--mode noray_lobby")
		Main.main.configuration.lobby_args.append("--mode lobby")
	Main.open_mode(P2PHostMode.new())
	(Main.main.mode as P2PHostMode).lobby_name = $VBoxContainer/NameInput.text
	(Main.mode as P2PHostMode).my_member_data.name = $VBoxContainer/NameInput.text
	(Main.main.mode as P2PHostMode).host_with_lan()
	(get_parent() as SubMenuHolder).open_menu("host_menu")


func _on_join_pressed() -> void:
	(get_parent() as SubMenuHolder).open_menu("client_menu")


func _on_check_button_pressed() -> void:
	$VBoxContainer/Advanced.visible = not $VBoxContainer/Advanced.visible
