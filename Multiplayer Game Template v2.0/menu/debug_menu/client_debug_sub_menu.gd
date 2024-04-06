extends DebugSubMenu

func _on_back_pressed():
	Main.main.mode.close()
	holder.open_menu(DebugSubMenuHolder.menu_options.DEFAULT)


func _on_join_pressed():
	var ip = $VBoxContainer/VBoxContainer/LineEdit.text
	if Main.main.mode is ClientMode:
		(Main.main.mode as ClientMode).join_server(ip)
