class_name GameLoadSyncroniser
extends Node
#class for keeping track of how many peers have loaded the game and alerting lobby when all loading is complete

signal all_loading_complete

var lobby : Lobby
var on_game_loaded : Signal
var loaded_game_count : int = 0


func initiate_loading() -> void:
	load_game.rpc()
	
	
@rpc("authority", "call_local")
func load_game() -> void:
	if not on_game_loaded.is_connected(_on_loading_complete):
		on_game_loaded.connect(_on_loading_complete)
	lobby.load_game()
	
	
func _on_loading_complete() -> void:
	#on loading complete for this one peer, not all peers
	if lobby.is_master:
		loaded_game_count += 1
		review_loading_status()
	else:
		submit_game_loaded.rpc_id(1)
		
		
@rpc("any_peer")
func submit_game_loaded() -> void:
	if lobby.is_master:
		loaded_game_count += 1
		review_loading_status()


func review_loading_status() -> void:
	if loaded_game_count == lobby.members.size() + 1:
		#loading complete for all peers
		all_loading_complete.emit()
