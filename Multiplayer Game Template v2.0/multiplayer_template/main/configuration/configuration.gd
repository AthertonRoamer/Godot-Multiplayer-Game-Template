class_name Configuration
extends Resource

@export_group("Ports")
@export var server_port : int = 3000 #port that dedicated server hosts game on
@export var lobby_manager_port : int = 4000 #port that lobby manager on server/host uses to connect to sattelite lobby processes
@export var starting_lobby_port : int = 5000 #each lobby hosts a game on a different port, starting here and incrementing per lobby
@export_subgroup("LAN Server Browser")
@export var listen_port : int = 3001
@export var broadcast_port : int = 3002

@export_group("Menu")
@export var menu_scene : PackedScene = preload("res://multiplayer_template/menu/main_menu/main_menu.tscn")

@export_group("Lobby")
@export var lobby_scene : PackedScene = preload("res://multiplayer_template/lobby_system/lobby/lobby.tscn")
@export var lobby_manager_scene : PackedScene = preload("res://multiplayer_template/lobby_system/lobby_manager/lobby_manager.tscn")
@export var lobby_database_scene : PackedScene = preload("res://multiplayer_template/lobby_system/lobby_database/lobby_database.tscn")
@export var matchmaker_scene : PackedScene = preload("res://multiplayer_template/lobby_system/matchmaker/matchmaker.tscn")

@export_subgroup("Serialization Scripts")
@export var lobby_data_script : Script = LobbyData
@export var lobby_member_script : Script = LobbyMember
@export var lobby_stats_script : Script = LobbyStats

@export_subgroup("Arguments")
@export var lobby_args : Array[String] = ["--mode lobby"]

@export_group("Game")
@export var game_manager_scene : PackedScene = preload("res://multiplayer_template/game_manager/basic_game_manager/basic_game_manager.tscn")
@export var game_scene : PackedScene

@export_group("Dynamic")
@export var dynamic_config_script : Script #allows you to run code if necessary during config step


func configure(main : Main) -> void:
	if dynamic_config_script != null:
		var dynamic_config = dynamic_config_script.new()
		if dynamic_config != null:
			if dynamic_config is DynamicConfiguration:
				dynamic_config.dynamic_configure(main)
