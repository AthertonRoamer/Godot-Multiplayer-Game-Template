class_name LobbyMode
extends Mode

var lobby_manager : LobbyManager
var lobby : Lobby

var lan_broadcast : bool = false

var default_port : int

func _init() -> void:
	id = "lobby"
	tag_list.append("lobby")


func open() -> void:
	super()
	default_port = Network.port #save default port for later
	lobby = Main.main.lobby_scene.instantiate()
	lobby.is_master = true
	Main.main.add_child(lobby, true)
	lobby_manager = Main.main.lobby_manager_scene.instantiate()
	Main.main.add_child(lobby_manager, true)
	
	Main.output("Opening lobby mode")


func close() -> void:
	Network.port = default_port #restore default port
	lobby_manager.close_peer()
	lobby_manager.queue_free()
	lobby.queue_free()
	Network.close_peer()
	super()
	Main.output("Closing lobby mode")
	
	
func launch_server() -> void:
	Network.port = lobby.stats.lobby_port
	Network.max_clients = lobby.stats.max_members
	Network.initiate_enet_server()
	if lan_broadcast:
		Network.server_browser.broadcast_data["type"] = "lobby"
		Network.server_browser.broadcast_data["port"] = Network.port
		Network.server_browser.broadcast_data["server_name"] = lobby.stats.name
		Network.server_browser.start_broadcast()
	
	
func get_game() -> Node:
	if lobby.game_manager.has_method("get_game"):
		return lobby.game_manager.get_game()
	else:
		Main.output("CRITICAL ERROR: Get game returned null")
		return null
