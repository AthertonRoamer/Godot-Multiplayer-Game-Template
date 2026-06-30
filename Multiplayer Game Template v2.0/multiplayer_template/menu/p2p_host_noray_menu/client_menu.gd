extends SubMenu


func opened() -> void:
	Main.open_mode(ClientMode.new())
	(Main.main.mode as ClientMode).launch_local_client()
	Network.server_browser.found_server.connect(_on_server_list_updated)
	Main.output("Opening client menu")
	Main.mode.lobby.game_manager.starting_game.connect($"../.."._on_game_starting)
	Main.mode.lobby.game_manager.ending_game.connect($"../.."._on_game_ending)
	
	
func closed() -> void:
	if Main.main.mode:
		(Main.main.mode as ClientMode).close_local_client()
	if Network.connected_to_server.is_connected(_on_connected_to_server):
		Network.connected_to_server.disconnect(_on_connected_to_server)
	Network.server_browser.found_server.disconnect(_on_server_list_updated)
	print("closing client menu")
	$VBoxContainer/Connecting.visible = false
	$VBoxContainer/JoinNoray.disabled = false


func _on_join_noray_pressed() -> void:
	if $VBoxContainer/GameIDInput.text != "":
		(Main.main.mode as ClientMode).my_member_data.name = $"../DefaultMenu/VBoxContainer/NameInput".text
		(Main.main.mode as ClientMode).join_noray_lobby($VBoxContainer/GameIDInput.text)
		if not Network.connected_to_server.is_connected(_on_connected_to_server):
			Network.connected_to_server.connect(_on_connected_to_server)
		if not Network.connection_failed.is_connected(_on_connection_failed):
			Network.connection_failed.connect(_on_connection_failed)
		$VBoxContainer/Connecting.text = "Connecting..."
		$VBoxContainer/Connecting.visible = true
		$VBoxContainer/JoinNoray.disabled = true #disabling should only be used with modified noray script
		
		
func _on_connection_failed() -> void:
	$VBoxContainer/Connecting.text = "Connection Failed"
	$VBoxContainer/JoinNoray.disabled = false
	
		
func join_local_lobby(ip : String, data : Dictionary) -> void:
	(Main.main.mode as ClientMode).my_member_data.name = $"../DefaultMenu/VBoxContainer/NameInput".text
	var port := 5000
	if data.has("port"):
		port = data["port"]
	Network.connected_to_server.connect(_on_connected_to_server)
	(Main.main.mode as ClientMode).direct_join_lobby(ip, port)
	
	
func _on_connected_to_server() -> void:
	(get_parent() as SubMenuHolder).open_menu("joined_client_menu")
	
	
func _on_server_list_updated(_lobby_name : String, _ip : String, _data : Dictionary) -> void:
	for child in $VBoxContainer/LobbyDisplayHolder.get_children():
		child.queue_free()
	for ip in Network.server_browser.found_servers:
		var data = Network.server_browser.found_servers[ip]
		var lobby_display = preload("res://multiplayer_template/menu/p2p_host_noray_menu/local_lobby_display.tscn").instantiate()
		if data.has("server_name"):
			lobby_display.lobby_name = data["server_name"]
		lobby_display.lobby_ip = ip
		lobby_display.lobby_data = data
		lobby_display.handler = self
		$VBoxContainer/LobbyDisplayHolder.add_child(lobby_display)


func _on_back_pressed() -> void:
	Main.mode.close()
	$VBoxContainer/GameIDInput.text = ""
	(get_parent() as SubMenuHolder).open_menu()
