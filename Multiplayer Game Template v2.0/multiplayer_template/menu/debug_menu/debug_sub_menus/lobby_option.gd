class_name LobbyOption
extends Button

var lobby_data : LobbyData

func _ready() -> void:
	text = lobby_data.stats.name
	

func _on_pressed():
	pass # Replace with function body.
