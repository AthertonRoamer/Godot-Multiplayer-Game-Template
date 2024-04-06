extends DebugSubMenu


func _on_open_server_pressed():
	Main.main.open_mode(DedicatedServerMode.new())
	holder.open_menu(DebugSubMenuHolder.menu_options.SERVER)


func _on_open_client_pressed():
	Main.main.open_mode(ClientMode.new())
	holder.open_menu(DebugSubMenuHolder.menu_options.CLIENT)
