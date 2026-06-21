extends Button

var lobby_name : String
var lobby_ip : String 
var lobby_data : Dictionary
var handler : Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "Join " + lobby_name + "'s Lobby"


func _on_pressed() -> void:
	handler.join_local_lobby(lobby_ip, lobby_data)
