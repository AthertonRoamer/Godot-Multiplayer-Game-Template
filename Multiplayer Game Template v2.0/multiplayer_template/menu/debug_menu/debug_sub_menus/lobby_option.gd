class_name LobbyOption
extends Button

signal selected(data : LobbyData)

var lobby_data : LobbyData

func _ready() -> void:
	text = lobby_data.stats.name
	

func _on_pressed():
	selected.emit(lobby_data)
	#(Main.mode as ClientMode).join_lobby(lobby_data)
	#var member : LobbyMember = Lobby.lobby_member_class.new()
	#member.name = name_line_edit.text
	#(Main.mode as ClientMode).request_membership_in_lobby(member)
