class_name UPNPLobbyMode
extends LobbyMode


var upnp_manager : UPNPManager

func _init() -> void:
	id = "upnp_lobby"
	tag_list.append("lobby")
	

func open() -> void:
	upnp_manager = UPNPManager.new()
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
