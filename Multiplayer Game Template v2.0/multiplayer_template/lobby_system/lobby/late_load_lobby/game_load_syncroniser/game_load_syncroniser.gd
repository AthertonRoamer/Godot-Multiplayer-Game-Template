class_name GameLoadSyncroniser
extends Node
#class for keeping track of how many clients have loaded

var lobby : Lobby
var on_game_loaded : Signal
var loaded_game_count : int = 0


func initiate_loading() -> void:
	load_game.rpc()
	
	
@rpc("authority", "call_local")
func load_game() -> void:
	on_game_loaded.connect(_on_loading_complete)
	lobby.load_game()
	
	
@rpc("any_peer")
func submit_game_loaded() -> void:
	if lobby.is_master:
		loaded_game_count += 1
	
	
func _on_loading_complete() -> void:
	if lobby.is_master:
		loaded_game_count += 1
	else:
		submit_game_loaded.rpc_id(1)
