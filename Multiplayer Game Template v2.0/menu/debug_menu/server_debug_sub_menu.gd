extends DebugSubMenu


func _on_launch_pressed():
	if Main.main.mode is DedicatedServerMode:
		(Main.main.mode as DedicatedServerMode).launch_server()


func _on_launch_lan_pressed():
	if Main.main.mode is DedicatedServerMode:
		(Main.main.mode as DedicatedServerMode).launch_local_server()


func _on_back_pressed():
	Main.main.mode.close()
	holder.open_menu()
