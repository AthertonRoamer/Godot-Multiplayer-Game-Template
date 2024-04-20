class_name LobbyManager
extends NetworkManager

@export var lobby_scene : PackedScene = preload("res://lobby_system/lobby/lobby.tscn")
@export var lobby_args : Array[String] = ["--mode lobby"]
var master_ip : String = "127.0.0.1"

var is_master : bool = false


func _ready() -> void:
	super()
	Main.main.about_to_quit.connect(_on_about_to_quit)
	peer_disconnected.connect(_lobby_disconnected)
	connected_to_server.connect(_connected_to_master_lobby_manager)
	server_disconnected.connect(_server_disconected)
	scope = Scope.Local
	if is_master:
		initiate_enet_server()
	else:
		connection_failed.connect(_on_connection_to_server_failed)
		initiate_enet_client(master_ip)
		
	
func launch_lobby() -> void:
	Main.main.output("Launching new lobby")
	Main.main.instance_launcher.launch_instance(lobby_args)
	
	
func _on_connection_to_server_failed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST) #if satellite lobby fails to reach main lobby manager, kill the instance
	
	
func _lobby_disconnected(id : int) -> void:
	if is_master:
		(Main.main.mode as DedicatedServerMode).lobby_database.remove_data_by_id(id)
		
		
func _connected_to_master_lobby_manager() -> void:
	Main.main.output("Connected to master lobby manager")
	submit_update()
	
	
func _server_disconected() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	
	
func submit_update() -> void:
	Main.main.output("Submitting update")
	var data : Dictionary = (Main.main.mode as LobbyMode).lobby.serialize_to_lobby_data_dictionary()
	submit_updated_lobby_data.rpc_id(1, data)
	
	
@rpc("reliable", "any_peer")
func submit_updated_lobby_data(data : Dictionary) -> void:
	if is_master:
		Main.main.output("Recieved a lobby data update")
		var sender_id : int = multiplayer.get_remote_sender_id()
		data["lobby_id"] = sender_id
		(Main.main.mode as DedicatedServerMode).lobby_database.update_data_from_dictionary(data)
		
		
@rpc("reliable")
func request_lobby_data() -> void:
	if !is_master:
		submit_update()
	

@rpc("reliable") 
func kill_lobby() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	
	
func _on_about_to_quit() -> void:
	if is_master:
		kill_lobby.rpc()
		OS.delay_msec(250) #delay allows time for remote procedural call to take place (I think - I know that without the delay the lobby satellites won't close

