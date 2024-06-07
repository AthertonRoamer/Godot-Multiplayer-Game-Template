class_name LobbyMode
extends Mode

var lobby_manager : LobbyManager
var lobby : Lobby

var default_port : int

func _init() -> void:
	id = "lobby"


func open() -> void:
	super()
	default_port = Network.port #save default port for later
	lobby_manager = Main.main.lobby_manager_scene.instantiate()
	Main.main.add_child(lobby_manager)
	lobby = Main.main.lobby_scene.instantiate()
	lobby.is_master = true
	Main.main.add_child(lobby)
	Main.output("Opening lobby mode")


func close() -> void:
	Network.port = default_port #restore default port
	lobby_manager.close_peer()
	lobby_manager.queue_free()
	lobby.queue_free()
	super()
	Main.output("Closing lobby mode")
	
	
func launch_server() -> void:
	Network.port = lobby.stats.lobby_port
	Network.max_clients = lobby.stats.max_members
	Network.initiate_enet_server()
