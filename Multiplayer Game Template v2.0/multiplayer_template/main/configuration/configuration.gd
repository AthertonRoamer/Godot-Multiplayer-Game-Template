class_name Configuration
extends Resource

@export_group("Scenes")
@export var menu_scene : PackedScene = preload("res://multiplayer_template/menu/main_menu/main_menu.tscn")
@export var lobby_manager_scene : PackedScene = preload("res://multiplayer_template/lobby_system/lobby_manager/lobby_manager.tscn")
@export var lobby_scene : PackedScene = preload("res://multiplayer_template/lobby_system/lobby/lobby.tscn")
@export var lobby_database_scene : PackedScene = preload("res://multiplayer_template/lobby_system/lobby_database/lobby_database.tscn")
@export var matchmaker_scene : PackedScene = preload("res://multiplayer_template/lobby_system/matchmaker/matchmaker.tscn")

@export_group("Arguments")
@export var arg_array : Array[String] = []

@export_group("Lobby Serialization Scripts")
@export var lobby_data_script : Script = LobbyData
@export var lobby_member_script : Script = LobbyMember
@export var lobby_stats_script : Script = LobbyStats

@export_group("Dynamic")
@export var dynamic_config_script : Script


func configure(main : Main) -> void:
	main.menu_scene = menu_scene
	main.lobby_manager_scene = lobby_manager_scene
	main.lobby_scene = lobby_scene
	main.lobby_database_scene = lobby_database_scene
	main.matchmaker_scene = matchmaker_scene
	
	main.simulated_args = arg_array.filter(validate_argument)
	
	Lobby.lobby_data_class = lobby_data_script
	Lobby.lobby_member_class = lobby_member_script
	Lobby.lobby_stats_class = lobby_stats_script
	
	var dynamic_config = dynamic_config_script.new()
	if dynamic_config != null:
		if dynamic_config is DynamicConfiguration:
			dynamic_config.dynamic_configure(main)
			
			
func validate_argument(arg : String) -> bool:
	if not arg.rsplit(" ").size() == 2:
		push_warning("Invalid arg in configuration: \"" + arg + "\"")
		return false
	return true
