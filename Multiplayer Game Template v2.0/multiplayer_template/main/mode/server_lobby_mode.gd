class_name ServerLobbyMode
extends LobbyMode

var matchmaker : Matchmaker

func _init() -> void:
	id = "server_lobby"
	tag_list.append("lobby")


func open() -> void:
	#super()
	is_open = true
	default_port = Network.port #save default port for later
	lobby = Main.main.lobby_scene.instantiate()
	lobby.is_master = true
	Main.main.add_child(lobby, true)
	matchmaker = Main.main.matchmaker_scene.instantiate() #
	Main.main.add_child(matchmaker, true)
	#lobby_manager = Main.main.lobby_manager_scene.instantiate()
	#Main.main.add_child(lobby_manager, true)
	
	Main.output("Opening server_lobby mode")


func close() -> void:
	is_open = false
	if Main.main.mode == self:
		Main.main.mode = null
	Network.port = default_port #restore default port
	#lobby_manager.close_peer()
	#lobby_manager.queue_free()
	
	lobby.queue_free()
	Network.close_peer()
	#super()
	Main.output("Closing server_lobby mode")
