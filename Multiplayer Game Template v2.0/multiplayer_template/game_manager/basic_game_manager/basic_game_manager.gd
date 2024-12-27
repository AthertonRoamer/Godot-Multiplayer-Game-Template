class_name BasicGameManager
extends GameManager
##Minimalistic implimentation of game manager which can be easily used without extending it first

#To Use:
#Set game_scene to the "main scene" of your game, i.e. the scene which is the root of your game itself
#Put anything you want to happen when the game loads in the _ready() function of said scene
#Give the root node of the scene a start() method, which will be called by the BasicGameManager when the game starts
#And an end() method, which will be called to end the game

#if you need to access lobby data (such as the stats or the member's data), BasicGameManager (GameManager) 
#has a lobby variable - you can acces the BasicGameManager by using get_parent() on the root node of the game_scene


@export var game_scene : PackedScene = preload("res://multiplayer_template/demo_games/demo_late_load_lobby_game/DemoOne.tscn")
var game : Node

func load_game() -> void:
	super()
	if game_scene != null:
		game = game_scene.instantiate()
		add_child(game)
	else:
		push_warning("BasicGameManager cannot load game because it does not have a game scene to load")


func start_game() -> void:
	super()
	if game != null:
		if game.has_method("start"):
			game.start()
		else:
			push_warning("BasicGameManager cannot start game because it does not have a start method")
	else:
		push_warning("BasicGameManager cannot start game because it has not yet loaded the game (the game node is null)")


func end_game() -> void:
	super()
	if game != null:
		if game.has_method("end"):
			game.end()
		else:
			push_warning("BasicGameManager cannot end game because it does not have a end method")
	else:
		push_warning("BasicGameManager cannot end game because it has not yet loaded the game (the game node is null)")
