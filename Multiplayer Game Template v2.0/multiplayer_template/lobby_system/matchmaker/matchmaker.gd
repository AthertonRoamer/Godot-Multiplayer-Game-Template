class_name Matchmaker
extends Node
##node on client which receives lobby data from server and determines which lobby to join, or requests new lobby etc

var database : LobbyDatabase
var is_master : bool = false
var active : bool = true #to make sure this node doesn't fire of rpcs when in lobby


func _ready() -> void:
	if is_master:
		database = (Main.main.mode as DedicatedServerMode).lobby_database
	else:
		database = Main.main.lobby_database_scene.instantiate() 
		add_child(database)
		Network.connected_to_server.connect(_on_connected_to_server)
		Network.server_disconnected.connect(_on_server_disconnected)
		Network.peer_closed.connect(_on_peer_closed)
	database.data_changed.connect(_on_data_changed)


@rpc("reliable")
func broadcast_lobby_data(data : Array) -> void:
	if not is_master:
		Main.output("Reiceived a lobby data update")
		database.update_data_from_array(data)


@rpc("reliable", "any_peer")
func request_lobby_data() -> void:
	if is_master:
		var id : int = multiplayer.get_remote_sender_id()
		broadcast_lobby_data.rpc_id(id, database.get_data_as_array()) 
		
		
func _on_data_changed() -> void:
	if is_master:
		broadcast_lobby_data.rpc(database.get_data_as_array())
		
		
func _on_connected_to_server() -> void:
	if active:
		request_lobby_data.rpc_id(1)
		
		
func _on_server_disconnected() -> void:
	database.clear_data()
	
	
func _on_peer_closed() -> void:
	database.clear_data()
