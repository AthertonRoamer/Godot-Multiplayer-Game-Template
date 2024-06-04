class_name ClientMode
extends Mode

var lobby : Lobby
var matchmaker : Matchmaker

func _init() -> void:
	id = "client"


func open() -> void:
	super()
	
	matchmaker = Main.main.matchmaker_scene.instantiate()
	Main.main.add_child(matchmaker)
	
	lobby = Main.main.lobby_scene.instantiate()
	Main.main.add_child(lobby)
	
	Main.output("Opening client mode") 
	
	
func close() -> void:
	Network.close_peer()
	close_local_client()
	
	matchmaker.queue_free()
	lobby.queue_free()
	Main.output("Closing client mode")
	super()
	
	
func join_server(ip : String):
	Network.initiate_enet_client(ip)
	
	
func launch_local_client() -> void:
	Network.server_browser.start_listening()
	
	
func close_local_client() -> void:
	Network.server_browser.stop_listening()
	
	
func join_lobby(data : LobbyData) -> void:
	var ip : String = data.stats.ip
	if ip == "":
		ip = "127.0.0.1"
	Network.close_peer()
	Network.port = data.stats.lobby_port
	Network.initiate_enet_client(ip)
	
	

