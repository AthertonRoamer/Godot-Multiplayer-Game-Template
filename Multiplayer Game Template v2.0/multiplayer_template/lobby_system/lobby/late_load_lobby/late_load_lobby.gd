class_name LateLoadLobby
extends Lobby

#lobby which after all players have joined, commands the players to load the game.
#Once all players have reported that they have loaded the game, the lobby starts the game

@export var game_load_syncroniser : Node

func _ready() -> void:
	super()
	game_load_syncroniser.lobby = self
	game_load_syncroniser.on_game_loaded = game_manager.game_loaded
	
	
func initiate_loading() -> void:
	pass
	
	

