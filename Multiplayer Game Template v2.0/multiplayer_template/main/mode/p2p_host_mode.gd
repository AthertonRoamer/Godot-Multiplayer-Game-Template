class_name P2PHostMode
extends Mode

enum CLIENT_STATE {NOT_CONNECTED, CONNECTING_TO_LOBBY, CONNECTED_TO_LOBBY}

var state : int = CLIENT_STATE.NOT_CONNECTED
var lobby : Lobby
var lobby_manager : LobbyManager 
var lobby_database : LobbyDatabase

var my_member_data : LobbyMember = null

#var has_lobby_up_and_running

func _init() -> void:
	id = "p2p_host"
	Network.connected_to_server.connect(_on_connected_to_server)
	Network.connection_failed.connect(_on_connection_failed)
	Network.server_disconnected.connect(_on_disconnected_to_server)


func open() -> void:
	super()
	
	lobby = Main.main.lobby_scene.instantiate()
	Main.main.add_child(lobby)
	
	lobby_manager = Main.main.lobby_manager_scene.instantiate()
	Main.main.add_child(lobby_manager)
	
	lobby_database = Main.main.lobby_database_scene.instantiate()
	Main.main.add_child(lobby_database)
	
	Main.output("Opening p2p host mode") 
	
	
func close() -> void:
	Network.close_peer()
	
	lobby.queue_free()
	lobby_manager.queue_free()
	lobby_database.queue_free()
	
	Network.port = Main.main.configuration.server_port #reset Network port to default
	
	Main.output("Closing p2p host mode")
	super()
	
	
func _on_lobby_data_changed() -> void:
	Main.output("New lobby data:\n" + str(lobby_database.data))
	
	
func launch_lobby() -> void:
	if lobby_database.data.size() < 1: #only allow one lobby at a time
		lobby_manager.launch_lobby()
		


func join_lobby(data : LobbyData, member_data : LobbyMember) -> void:
	state = CLIENT_STATE.CONNECTING_TO_LOBBY
	my_member_data = member_data
	var ip : String = data.stats.ip
	if ip == "":
		ip = "127.0.0.1"
	Network.close_peer()
	Network.port = data.stats.lobby_port
	Network.initiate_enet_client(ip)
	
	
func request_membership_in_lobby(member : LobbyMember) -> void:
	if state == CLIENT_STATE.CONNECTED_TO_LOBBY:
		var serialized_member : Dictionary = member.serialize_to_dictionary()
		lobby.initiate_membership_request(serialized_member)
		Main.output("Requesting membership in lobby")
	else:
		push_warning("In p2p host mode tried to request membership in lobby while not connected to lobby")
	
	
func _on_connected_to_server() -> void:
	match state:
		CLIENT_STATE.CONNECTING_TO_LOBBY:
			state = CLIENT_STATE.CONNECTED_TO_LOBBY
			request_membership_in_lobby(my_member_data)
			
		
func _on_connection_failed() -> void:
	match state:
		CLIENT_STATE.CONNECTING_TO_LOBBY:
			Network.port = Main.main.configuration.server_port
			
		
func _on_disconnected_to_server() -> void:
	match state:
		CLIENT_STATE.CONNECTED_TO_LOBBY:
			if lobby.game_manager.is_game_loaded:
				lobby.end_game()
			Network.port = Main.main.configuration.server_port
