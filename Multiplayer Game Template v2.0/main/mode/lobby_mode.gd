class_name LobbyMode
extends Mode

var lobby_manager : LobbyManager
var lobby : Lobby

func _init() -> void:
	id = "lobby"


func open() -> void:
	super()
	lobby_manager = Main.main.lobby_manager_scene.instantiate()
	Main.main.add_child(lobby_manager)
	lobby = Main.main.lobby_scene.instantiate()
	Main.main.add_child(lobby)
	Main.main.output("Opening lobby mode")
	
	
func close() -> void:
	lobby_manager.close_peer()
	lobby_manager.queue_free()
	lobby.queue_free()
	super()
	Main.main.output("Closing lobby mode")
