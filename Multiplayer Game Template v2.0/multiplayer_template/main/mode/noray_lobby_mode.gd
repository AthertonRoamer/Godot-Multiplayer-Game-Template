class_name NorayLobbyMode
extends LobbyMode


var noray_manager : NorayManager

func _init() -> void:
	id = "noray_lobby"
	tag_list.append("lobby")
	

func open() -> void:
	noray_manager = NorayManager.new()
	Main.main.add_child(noray_manager)
	super()
	
	Main.output("Opening noray lobby mode")


func close() -> void:
	super()
	noray_manager.queue_free()
	Main.output("Closing noray lobby mode")


func launch_server() -> void:
	#Network.port = lobby.stats.lobby_port
	Network.max_clients = lobby.stats.max_members
	
	#Network.initiate_enet_server()
	await noray_manager.initiate_noray_server()
	lobby.stats.lobby_port = Network.port
	lobby.stats.game_id = noray_manager.game_id
	
	Network.server_browser.broadcast_data["type"] = "lobby"
	Network.server_browser.broadcast_data["port"] = Network.port
	Network.server_browser.broadcast_data["server_name"] = lobby.stats.name
	Network.server_browser.start_broadcast()
	
	
	
	
	
#func _on_upnp_bound_successfully() -> void:
	#if not lobby.members.is_empty():
		#var authoritative_member_id = lobby.members[0].id
		#lobby.deliver_external_address.rpc_id(authoritative_member_id, upnp_manager.external_ip, upnp_manager.external_port)
