class_name LobbyOption
extends Button

signal selected(data : LobbyData)

var lobby_data : LobbyData

func _ready() -> void:
	text = lobby_data.stats.name
	disabled = not lobby_data.stats.available_to_join
	

func _on_pressed():
	selected.emit(lobby_data)
