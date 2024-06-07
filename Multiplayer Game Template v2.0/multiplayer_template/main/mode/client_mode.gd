class_name ClientMode
extends Mode

enum CLIENT_STATE {NOT_CONNECTED, CONNECTING_TO_SERVER, CONNECTED_TO_SERVER, CONNECTING_TO_LOBBY, CONNECTED_TO_LOBBY}

var state : int = CLIENT_STATE.NOT_CONNECTED
var lobby : Lobby
var matchmaker : Matchmaker

var server_ip : String = ""
var server_port : int = 3000


func _init() -> void:
	id = "client"
	Network.connected_to_server.connect(_on_connected_to_server)
	Network.connection_failed.connect(_on_connection_failed)
	Network.server_disconnected.connect(_on_disconnected_to_server)


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
	state = CLIENT_STATE.CONNECTING_TO_SERVER
	server_ip = ip #save server ip for later
	server_port = Network.port #save server port for later
	Network.initiate_enet_client(ip)
	
	
func launch_local_client() -> void:
	Network.server_browser.start_listening()
	
	
func close_local_client() -> void:
	Network.server_browser.stop_listening()
	
	
func join_lobby(data : LobbyData) -> void:
	state = CLIENT_STATE.CONNECTING_TO_LOBBY
	var ip : String = data.stats.ip
	if ip == "":
		ip = "127.0.0.1"
	Network.close_peer()
	server_ip = Network.active_ip
	server_port = Network.port #save server port for rejoining server later
	Network.port = data.stats.lobby_port
	Network.initiate_enet_client(ip)
	
	
func request_membership_in_lobby(member : LobbyMember) -> void:
	pass
	
	
func _on_connected_to_server() -> void:
	match state:
		CLIENT_STATE.CONNECTING_TO_SERVER:
			state = CLIENT_STATE.CONNECTED_TO_SERVER
		CLIENT_STATE.CONNECTING_TO_LOBBY:
			state = CLIENT_STATE.CONNECTED_TO_LOBBY
			
		
func _on_connection_failed() -> void:
	match state:
		CLIENT_STATE.CONNECTING_TO_SERVER:
			state = CLIENT_STATE.NOT_CONNECTED
		CLIENT_STATE.CONNECTING_TO_LOBBY:
			Network.port = server_port
			join_server(server_ip)
			
		
func _on_disconnected_to_server() -> void:
	match state:
		CLIENT_STATE.CONNECTED_TO_SERVER:
			state = CLIENT_STATE.NOT_CONNECTED
		CLIENT_STATE.CONNECTED_TO_LOBBY:
			Network.port = server_port
			join_server(server_ip)
