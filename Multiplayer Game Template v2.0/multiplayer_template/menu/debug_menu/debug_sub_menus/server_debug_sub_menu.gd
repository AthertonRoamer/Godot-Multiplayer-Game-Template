extends SubMenu


func _on_launch_pressed():
	if Main.mode is DedicatedServerMode:
		(Main.mode as DedicatedServerMode).launch_server()


func _on_launch_lan_pressed():
	if Main.mode is DedicatedServerMode:
		(Main.mode as DedicatedServerMode).launch_local_server()


func _on_back_pressed():
	Main.mode.close()
	holder.open_menu()


func _on_launch_lobby_pressed():
	Main.mode.launch_lobby()


func _on_print_lobby_data_pressed():
	(Main.mode as DedicatedServerMode).lobby_database.output_data()
