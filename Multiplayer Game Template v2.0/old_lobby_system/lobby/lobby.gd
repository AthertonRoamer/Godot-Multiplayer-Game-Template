#class_name Lobby
extends Node

signal closed

var data : LobbyData
var lobby_members : Array[LobbyMemberData]

func _ready() -> void:
	if data != null:
		name = str(data.id)

@rpc("reliable", "any_peer")
func request_close() -> void:
	if Network.is_server:
		close.rpc()
	
	
func close() -> void:
	closed.emit()
