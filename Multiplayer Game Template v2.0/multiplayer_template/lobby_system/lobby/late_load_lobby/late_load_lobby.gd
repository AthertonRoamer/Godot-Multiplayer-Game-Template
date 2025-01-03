class_name LateLoadLobby
extends Lobby

#lobby which after all players have joined, commands the players to load the game.
#Once all players have reported that they have loaded the game, the lobby starts the game

@export var game_load_syncroniser : GameLoadSyncroniser

func _ready() -> void:
	super()
	game_load_syncroniser.lobby = self
	game_load_syncroniser.on_game_loaded = game_manager.game_loaded
	game_load_syncroniser.all_loading_complete.connect(_on_all_loading_complete)
	
	
func initiate_loading() -> void:
	game_load_syncroniser.initiate_loading()
	
	
func begin_game() -> void:
	Network.refuse_new_connections = true
	clear_unregistered_peers()
	stats.available_to_join = false
	if is_master:
		initiate_loading()
	game_began.emit()
	
	
func _on_all_loading_complete() -> void:
	if is_master:
		trigger_game_start.rpc()
	
	
@rpc("call_local")
func trigger_game_start() -> void:
	start_game()
	
	
func end_game() -> void:
	Network.refuse_new_connections = false
	stats.available_to_join = true
	super()
	
	
