class_name UPNPLobbyMode
extends LobbyMode


var upnp_manager : UPNPManager

func _init() -> void:
	id = "upnp_lobby"
	tag_list.append("lobby")
	

func open() -> void:
	upnp_manager = UPNPManager.new()
	upnp_manager.upnp_bound_successfully.connect(_on_upnp_bound_successfully)
	Main.main.add_child(upnp_manager)
	super()
	
	Main.output("Opening upnp lobby mode")


func close() -> void:
	super()
	upnp_manager.queue_free()
	Main.output("Closing upnp lobby mode")


func launch_server() -> void:
	super()
	upnp_manager.trigger_setup_upnp(Network.port, Network.port)
	Network.server_browser.start_broadcast()
	
	
func _on_upnp_bound_successfully() -> void:
	if not lobby.members.is_empty():
		var authoritative_member_id = lobby.members[0].id
		lobby.deliver_external_address.rpc_id(authoritative_member_id, upnp_manager.external_ip, upnp_manager.external_port)
