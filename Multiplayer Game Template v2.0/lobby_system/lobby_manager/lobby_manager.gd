class_name LobbyManager
extends NetworkManager

@export var lobby_scene : PackedScene = preload("res://lobby_system/lobby/lobby.tscn")
@export var lobby_args : Array[String] = ["--mode lobby"]

func launch_lobby() -> void:
	Main.main.output("Launching new lobby")
	Main.main.instance_launcher.launch_instance(lobby_args)
