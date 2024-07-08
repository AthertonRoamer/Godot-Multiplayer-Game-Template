class_name GameManager
extends Node

#this node is loaded by the lobby when the lobby itself loads
#it serves as an interface for the lobby to load the game, recieve notice that the game has completed loading, and to start the game
#this class should be extended for your game

signal game_loaded

var lobby : Lobby

func load_game() -> void:
	game_loaded.emit()
	
	
func start_game() -> void:
	pass

