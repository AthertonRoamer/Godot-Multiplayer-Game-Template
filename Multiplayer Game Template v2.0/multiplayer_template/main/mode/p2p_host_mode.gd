class_name P2PHostMode
extends Mode

enum CLIENT_STATE {NOT_CONNECTED, CONNECTING_TO_LOBBY, CONNECTED_TO_LOBBY}

var state : int = CLIENT_STATE.NOT_CONNECTED
var lobby : Lobby
var lobby_manager : LobbyManager 
var lobby_database : LobbyDatabase

var my_member_data : LobbyMember = LobbyMember.new()

var has_authority : bool = false

var lobby_name : String = "Lobby Name"

func _init() -> void:
	id = "p2p_host"
	Network.connected_to_server.connect(_on_connected_to_server)
	Network.connection_failed.connect(_on_connection_failed)
	Network.server_disconnected.connect(_on_disconnected_to_server)


func open() -> void:
	super()
	
	lobby = Main.main.lobby_scene.instantiate()
	lobby.accepted_into_lobby.connect(_on_accepted_into_lobby)
	lobby.received_external_address.connect(_on_lobby_external_address_received)
	lobby.authority_acknowleged.connect(_on_authority_acknowleged)
	Main.main.add_child(lobby)
	
	lobby_manager = Main.main.lobby_manager_scene.instantiate()
	lobby_manager.is_master = true
	Main.main.add_child(lobby_manager)
	
	lobby_database = Main.main.lobby_database_scene.instantiate()
	Main.main.add_child(lobby_database)
	lobby_database.data_changed.connect(_on_lobby_data_changed)
	
	my_member_data = Lobby.lobby_member_class.new()
	
	Main.output("Opening p2p host mode") 
	
	
func close() -> void:
	Network.close_peer()
	
	lobby.queue_free()
	lobby_manager.queue_free()
	lobby_database.queue_free()
	
	Network.port = Main.main.configuration.server_port #reset Network port to default
	
	Main.output("Closing p2p host mode")
	super()
	
	
func host() -> void:
	Main.output("Hosting p2p game")
	launch_lobby()
	
	
func launch_lobby() -> void:
	if lobby_database.data.size() < 1: #only allow one lobby at a time
		lobby_manager.launch_lobby()
		


func join_lobby(data : LobbyData, member_data : LobbyMember) -> void:
	state = CLIENT_STATE.CONNECTING_TO_LOBBY
	my_member_data = member_data
	var ip : String = data.stats.ip
	if ip == "" or ip == "server":
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
		
		
func _on_accepted_into_lobby() -> void:
	pass
	
	
func _on_authority_acknowleged(member_has_authority : bool) -> void:
	has_authority = member_has_authority
	Main.output("Authority: " + str(has_authority))
	
	
func _on_lobby_external_address_received(ip : String, port : int) -> void:
	Main.output("Lobby external ip: " + ip + " external port: " + str(port))
		
		
func _on_lobby_data_changed() -> void: 
	match state:
		CLIENT_STATE.NOT_CONNECTED:
			if lobby_database.data.values().size() > 0:
				join_lobby(lobby_database.data.values()[0], my_member_data)
			
			
func shut_down_lobby() -> void:
	lobby_manager.close_all_lobbys()
			
			
func leave_lobby() -> void:
	lobby.leave_lobby()
	
	
func get_additional_lobby_args() -> Array[String]:
	return ["--name " + lobby_name]
	
	
func _on_connected_to_server() -> void:
	match state:
		CLIENT_STATE.CONNECTING_TO_LOBBY:
			state = CLIENT_STATE.CONNECTED_TO_LOBBY
			request_membership_in_lobby(my_member_data)
			
		
func _on_connection_failed() -> void:
	match state:
		CLIENT_STATE.CONNECTING_TO_LOBBY:
			Network.port = Main.main.configuration.server_port
	state = CLIENT_STATE.NOT_CONNECTED
			
		
func _on_disconnected_to_server() -> void:
	match state:
		CLIENT_STATE.CONNECTED_TO_LOBBY:
			if lobby.game_manager.is_game_loaded:
				lobby.end_game()
			Network.port = Main.main.configuration.server_port
	state = CLIENT_STATE.NOT_CONNECTED
