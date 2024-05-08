class_name ClientMode
extends Mode

var lobby_database : LobbyDatabase

func _init() -> void:
	id = "client"


func open() -> void:
	super()
	lobby_database = Main.main.lobby_database_scene.instantiate()
	Main.main.add_child(lobby_database)
	Main.main.output("Opening client mode") 
	
	
func close() -> void:
	Network.close_peer()
	close_local_client()
	lobby_database.queue_free()
	Main.main.output("Closing client mode")
	super()
	
	
func join_server(ip : String):
	Network.initiate_enet_client(ip)
	
	
func launch_local_client() -> void:
	Network.server_browser.start_listening()
	
	
func close_local_client() -> void:
	Network.server_browser.stop_listening()
	
	

