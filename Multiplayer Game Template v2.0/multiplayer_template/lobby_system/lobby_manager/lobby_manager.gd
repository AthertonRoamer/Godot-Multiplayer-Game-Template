class_name LobbyManager
extends NetworkManager

var lobby_args : Array[String] = ["--mode lobby"]
var master_ip : String = "127.0.0.1"

var is_master : bool = false
var lobby_port : int = 5000 #each lobby should have a different lobby port


func _ready() -> void:
	lobby_args = Main.main.configuration.lobby_args
	port = Main.main.configuration.lobby_manager_port
	lobby_port = Main.main.configuration.starting_lobby_port
	scope = Scope.Local
	super()
	peer_disconnected.connect(_lobby_disconnected)
	connected_to_server.connect(_connected_to_master_lobby_manager)
	server_disconnected.connect(_server_disconected)
	if is_master:
		initiate_enet_server()
	else:
		connection_failed.connect(_on_connection_to_server_failed)
		initiate_enet_client(get_master_ip())
		
	
func launch_lobby() -> void:
	Main.output("Launching new lobby")
	var full_lobby_args : Array[String] = lobby_args.duplicate()
	full_lobby_args.append(get_port_arg())
	Main.instance_launcher.launch_instance(full_lobby_args)
	
	
func _on_connection_to_server_failed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST) #if satellite lobby fails to reach main lobby manager, kill the instance
	
	
func _lobby_disconnected(id : int) -> void:
	if is_master:
		Main.mode.lobby_database.remove_data_by_id(id)
		
		
func _connected_to_master_lobby_manager() -> void:
	Main.output("Connected to master lobby manager")
	submit_update()
	
	
func _server_disconected() -> void:
	Main.output("server diconnected")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	
	
func submit_update() -> void: #update from sattelite lobby to main lobby manager
	Main.output("Submitting update") 
	var data : Dictionary = (Main.mode as LobbyMode).lobby.serialize_to_lobby_data_dictionary()
	submit_updated_lobby_data.rpc_id(1, data)
	
	
@rpc("reliable", "any_peer")
func submit_updated_lobby_data(data : Dictionary) -> void:
	if is_master:
		Main.output("Recieved a lobby data update")
		var sender_id : int = multiplayer.get_remote_sender_id()
		data["lobby_id"] = sender_id
		Main.main.mode.lobby_database.update_data_from_dictionary(data)
		
		
@rpc("reliable")
func request_lobby_data() -> void: #master requests updated lobby data from sattelite lobbies
	if !is_master:
		submit_update()


func get_port_arg() -> String:
	var header : String = "--lobby-port "
	header += str(lobby_port)
	lobby_port += 1
	return header
	
	
func get_master_ip() -> String:
	return master_ip
