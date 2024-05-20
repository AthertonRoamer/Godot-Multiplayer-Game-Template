extends Node
#lobby manager autoload

signal created_lobby(data : LobbyData)
signal closed_lobby(data : LobbyData)

@export var lobby_scene : PackedScene = preload("res://multiplayer_template/lobby_system/lobby/lobby.tscn")

var next_lobby_id : int = 0


#intended to be called from a client to the server
@rpc("any_peer", "reliable") 
func request_new_lobby(lobby_data : Dictionary) -> void:
	if Network.is_server:
		print("Server recieved request to create new lobby")
		lobby_data["id"] = get_next_lobby_id()
		create_lobby.rpc(lobby_data)


@rpc("call_local", "reliable")
func create_lobby(lobby_data : Dictionary) -> void:
	var lobby : Lobby = lobby_scene.instantiate()
	#lobby.data = LobbyData.deserialize_from_dictionary(lobby_data)
	print("Creating new lobby - Id: ", lobby.data.id, " Name: ", lobby.data.name)
	add_child(lobby)
	created_lobby.emit(lobby.data)
	
	
#this function is totally unfinished and needs to be wrapped up
func close_lobby(lobby : Lobby) -> void:
	if Network.is_server:
		lobby.close.rpc()
	closed_lobby.emit(lobby.data)
		


func get_lobbies() -> Array[Lobby]:
	var l : Array = get_children()
	l = l.filter(is_node_lobby)
	return l


func get_next_lobby_id() -> int:
	next_lobby_id += 1
	return next_lobby_id - 1


func is_node_lobby(node) -> bool:
	return node.is_instance_valid() and node is Lobby
