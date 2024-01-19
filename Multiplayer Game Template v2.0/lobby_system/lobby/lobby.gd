class_name Lobby
extends Node

signal closed

var data : LobbyData
var lobby_members : Array[LobbyMemberData]

func _ready() -> void:
	if data != null:
		name = str(data.id)
		
		
func close() -> void:
	closed.emit()
