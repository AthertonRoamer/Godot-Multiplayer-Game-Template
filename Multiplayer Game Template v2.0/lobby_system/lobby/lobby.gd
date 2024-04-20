class_name Lobby
extends Node

#class for a lobby, lobby is parent of the game scene and controls the game start etc

var stats : LobbyStats = LobbyStats.new()
var members : Array[LobbyMember]
var is_master : bool = false


func _ready() -> void:
	if Main.main.arg_dictionary.has("--lobby-port"):
		stats.lobby_port = int(Main.main.arg_dictionary["--lobby-port"])
	if is_master:
		(Main.main.mode as LobbyMode).launch_server()
	

func serialize_to_lobby_data_dictionary() -> Dictionary:
	var serialized_members : Array = []
	for m in members:
		serialized_members.append(m.serialize_to_dictionary())
	return {"stats" : stats.serialize_to_dictionary(), "members": serialized_members}

