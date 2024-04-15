class_name DedicatedServerMode
extends Mode

var lobby_manager : LobbyManager

func _init() -> void:
	id = "server"


func open() -> void:
	super()
	lobby_manager = Main.main.lobby_manager_scene.instantiate()
	lobby_manager.is_master = true
	Main.main.add_child(lobby_manager)
	Main.main.output("Opening server mode")
	
	
func close() -> void:
	close_server()
	lobby_manager.queue_free()
	Main.main.output("Closing server mode")
	super()


func launch_server() -> void:
	Network.initiate_enet_server()
	
	
func launch_local_server() -> void:
	Network.initiate_local_enet_server()
	
	
func close_server() -> void:
	Network.close_peer()
	Network.server_browser.stop_broadcast()
