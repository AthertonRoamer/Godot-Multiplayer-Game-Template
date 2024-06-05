extends SubMenu


func _on_open_server_pressed():
	Main.open_mode(DedicatedServerMode.new())
	holder.open_menu("server")

func _on_open_client_pressed():
	Main.open_mode(ClientMode.new())
	(Main.mode as ClientMode).launch_local_client()
	holder.open_menu("client")


func _on_test_pressed():
	pass
