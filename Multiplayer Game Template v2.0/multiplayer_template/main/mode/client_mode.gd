class_name ClientMode
extends Mode

enum CLIENT_STATE {NOT_CONNECTED, CONNECTING_TO_SERVER, CONNECTED_TO_SERVER, CONNECTING_TO_LOBBY, CONNECTED_TO_LOBBY}

var state : int = CLIENT_STATE.NOT_CONNECTED
	#set(s):
		#state = s
		#print("State to ", state)
		#print_stack()
var lobby : Lobby
var matchmaker : Matchmaker

var server_ip : String = ""
var server_port : int = 3000

var has_authority : bool = false
var my_member_data : LobbyMember = LobbyMember.new()

var noray_manager : NorayManager

func _init() -> void:
	id = "client"
	Network.connected_to_server.connect(_on_connected_to_server)
	Network.connection_failed.connect(_on_connection_failed)
	Network.server_disconnected.connect(_on_disconnected_to_server)


func open() -> void:
	super()
	
	matchmaker = Main.main.matchmaker_scene.instantiate() #
	Main.main.add_child(matchmaker, true)
	
	lobby = Main.main.lobby_scene.instantiate()
	lobby.authority_acknowleged.connect(_on_authority_acknowleged)
	lobby.accepted_into_lobby.connect(_on_accepted_into_lobby)
	Main.main.add_child(lobby, true)
	
	Main.output("Opening client mode") 
	server_port = Network.port #save default port so we can put it back when we close the mode
	
	
func close() -> void:
	Network.close_peer()
	close_local_client()
	
	matchmaker.queue_free()
	lobby.queue_free()
	
	Network.port = server_port #reset Network port to default
	
	Main.output("Closing client mode")
	
	super()
	
	
func join_server(ip : String):
	state = CLIENT_STATE.CONNECTING_TO_SERVER
	server_ip = ip #save server ip for later
	Network.initiate_enet_client(ip)
	
	
func launch_local_client() -> void:
	Network.server_browser.start_listening()
	
	
func close_local_client() -> void:
	Network.server_browser.stop_listening()
	
	
func direct_join_lobby(ip : String, port : int, member_data : LobbyMember = my_member_data) -> void:
	state = CLIENT_STATE.CONNECTING_TO_LOBBY
	my_member_data = member_data
	if ip == "server":
		ip = server_ip
	if ip == "":
		ip = "127.0.0.1"
	Network.close_peer()
	server_port = Network.port #save server port for rejoining server later
	Network.port = port
	Network.initiate_enet_client(ip)
	
	
func join_noray_lobby(game_id : String, member_data : LobbyMember = my_member_data) -> void:
	Network.close_peer()
	noray_manager = NorayManager.new()
	my_member_data = member_data
	server_port = Network.port
	state = CLIENT_STATE.CONNECTING_TO_LOBBY
	noray_manager.initiate_noray_client(game_id)


	
func join_lobby(data : LobbyData, member_data : LobbyMember = my_member_data) -> void:
	state = CLIENT_STATE.CONNECTING_TO_LOBBY
	my_member_data = member_data
	var ip : String = data.stats.ip
	if ip == "server":
		ip = server_ip
	if ip == "":
		ip = "127.0.0.1"
	Network.close_peer()
	server_port = Network.port #save server port for rejoining server later
	Network.port = data.stats.lobby_port
	Network.initiate_enet_client(ip)
	
	
func request_membership_in_lobby(member : LobbyMember) -> void:
	if state == CLIENT_STATE.CONNECTED_TO_LOBBY:
		var serialized_member : Dictionary = member.serialize_to_dictionary()
		lobby.initiate_membership_request(serialized_member)
		Main.output("Requesting membership in lobby")
	else:
		push_warning("In client mode tried to request membership in lobby while not connected to lobby")
		
		
func _on_accepted_into_lobby() -> void:
	pass
	
	
func _on_authority_acknowleged(member_has_authority : bool) -> void:
	has_authority = member_has_authority
	Main.output("Authority: " + str(has_authority))
	
	
func leave_lobby() -> void:
	lobby.leave_lobby()
	
	
func _on_connected_to_server() -> void:
	match state:
		CLIENT_STATE.CONNECTING_TO_SERVER:
			state = CLIENT_STATE.CONNECTED_TO_SERVER
			Main.output("Client mode connecting to server")
		CLIENT_STATE.CONNECTING_TO_LOBBY:
			state = CLIENT_STATE.CONNECTED_TO_LOBBY
			request_membership_in_lobby(my_member_data)
		_:
			Main.output("Connected to server but state is " + str(state))
			
		
func _on_connection_failed() -> void:
	match state:
		CLIENT_STATE.CONNECTING_TO_SERVER:
			state = CLIENT_STATE.NOT_CONNECTED
		CLIENT_STATE.CONNECTING_TO_LOBBY:
			Network.port = server_port
			join_server(server_ip)
			
		
func _on_disconnected_to_server() -> void:
	Main.output("Client mode disconnected to server " + str(state))
	match state:
		CLIENT_STATE.CONNECTED_TO_SERVER:
			state = CLIENT_STATE.NOT_CONNECTED
		CLIENT_STATE.CONNECTED_TO_LOBBY:
			if lobby.game_manager.is_game_loaded:
				lobby.end_game()
			Network.port = server_port
			if server_ip == "":
				Main.output("Cannot rejoin main server because server ip is invalid")
			else:
				Main.output("Attempting to join server")
				join_server(server_ip)
				

func get_game() -> Node:
	if lobby.game_manager.has_method("get_game"):
		return lobby.game_manager.get_game()
	else:
		Main.output("CRITICAL ERROR: Get game returned null")
		return null
