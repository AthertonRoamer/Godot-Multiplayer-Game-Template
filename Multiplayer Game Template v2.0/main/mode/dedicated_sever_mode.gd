class_name DedicatedServerMode
extends Mode

var lobby_manager : LobbyManager
var lobby_database : LobbyDatabase
var matchmaker : Matchmaker

func _init() -> void:
	id = "server"


func open() -> void:
	super()
	lobby_manager = Main.main.lobby_manager_scene.instantiate()
	lobby_manager.is_master = true
	Main.main.add_child(lobby_manager)
	
	lobby_database = Main.main.lobby_database_scene.instantiate()
	Main.main.add_child(lobby_database)
	
	matchmaker = Main.main.matchmaker_scene.instantiate()
	matchmaker.is_master = true
	Main.main.add_child(matchmaker)
	
	Main.main.output("Opening server mode")
	
	
func close() -> void:
	close_server()
	lobby_manager.queue_free()
	lobby_database.queue_free()
	matchmaker.queue_free()
	Main.main.output("Closing server mode")
	super()


func launch_server() -> void:
	Network.initiate_enet_server()
	
	
func launch_local_server() -> void:
	Network.initiate_local_enet_server()
	
	
func close_server() -> void:
	Network.close_peer()
	Network.server_browser.stop_broadcast()
