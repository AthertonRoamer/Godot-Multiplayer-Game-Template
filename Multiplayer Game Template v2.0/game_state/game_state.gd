extends Node

var player_name : String = "Player"

var players_info : Dictionary


func get_my_player_info() -> Dictionary:
	return {"name" : player_name}


func add_player(id : int, info : Dictionary) -> void:
	players_info[id] = info
	
	
func remove_player(id : int) -> void:
	players_info.erase(id)
	
	
func clear():
	players_info = {}
