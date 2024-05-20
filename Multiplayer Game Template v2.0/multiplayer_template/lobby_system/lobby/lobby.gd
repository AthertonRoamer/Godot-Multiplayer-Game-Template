class_name Lobby
extends Node

#class for a lobby, lobby is parent of the game scene and controls the game start etc

var stats : LobbyStats = LobbyStats.new()
var members : Array[LobbyMember]
var is_master : bool = false


func _ready() -> void:
	if Main.main.has_arg_option("--lobby-port"):
		stats.lobby_port = int(Main.main.get_arg_option_parameter("--lobby-port"))
		
	if Main.main.has_arg_option("--lobby-max-members"):
		stats.max_members = int(Main.main.get_arg_option_parameter("--lobby-max-members"))
	
	if is_master:
		(Main.main.mode as LobbyMode).launch_server()
		
	Network.peer_connected.connect(_on_peer_connected)
	Network.peer_disconnected.connect(_on_peer_disconnected)


func serialize_to_lobby_data_dictionary() -> Dictionary:
	var serialized_members : Array = []
	for m in members:
		serialized_members.append(m.serialize_to_dictionary())
	return {"stats" : stats.serialize_to_dictionary(), "members": serialized_members}
	
	
func _on_peer_connected(_id) -> void:
	stats.current_member_count = Network.client_count
	if is_master:
		get_lobby_manager().submit_update()
	
	
func _on_peer_disconnected(_id) -> void:
	stats.current_member_count = Network.client_count
	if is_master:
		get_lobby_manager().submit_update()


func get_lobby_manager() -> LobbyManager:
	return (Main.main.mode as LobbyMode).lobby_manager
