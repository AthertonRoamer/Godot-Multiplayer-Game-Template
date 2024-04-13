class_name DedicatedServerMode
extends Mode

func _init() -> void:
	id = "server"

var lobby_manager : LobbyManager

func open() -> void:
	lobby_manager = Main.main.lobby_manager_scene.instantiate()
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
