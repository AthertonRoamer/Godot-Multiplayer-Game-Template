class_name GameManager
extends Node

#this node is loaded by the lobby when the lobby itself loads
#it serves as an interface for the lobby to load the game, recieve notice that the game has completed loading, and to start the game
#this class should be extended for your game

signal game_loaded

var lobby : Lobby
var in_game : bool = false
var is_game_loaded : bool = false

func load_game() -> void:
	is_game_loaded = true
	game_loaded.emit()
	
	
func start_game() -> void:
	in_game = true
	
	
func end_game() -> void:
	in_game = false
	is_game_loaded = false
