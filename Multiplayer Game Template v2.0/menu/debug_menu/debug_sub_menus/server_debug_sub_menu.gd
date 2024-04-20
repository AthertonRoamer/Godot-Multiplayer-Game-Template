extends SubMenu


func _on_launch_pressed():
	if Main.main.mode is DedicatedServerMode:
		(Main.main.mode as DedicatedServerMode).launch_server()


func _on_launch_lan_pressed():
	if Main.main.mode is DedicatedServerMode:
		(Main.main.mode as DedicatedServerMode).launch_local_server()


func _on_back_pressed():
	Main.main.mode.close()
	holder.open_menu()


func _on_launch_lobby_pressed():
	Main.main.mode.lobby_manager.launch_lobby()


func _on_print_lobby_data_pressed():
	Main.main.output("All lobby data:")
	var dataset : Array = (Main.main.mode as DedicatedServerMode).lobby_database.data.values()
	for datum in dataset:
		Main.main.output(str((datum as LobbyData).serialize_to_dictionary()))
	if dataset.is_empty():
		Main.main.output("<No lobbys>")
		
