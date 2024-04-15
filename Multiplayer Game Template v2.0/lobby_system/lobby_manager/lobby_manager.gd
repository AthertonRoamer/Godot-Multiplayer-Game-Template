class_name LobbyManager
extends NetworkManager

@export var lobby_scene : PackedScene = preload("res://lobby_system/lobby/lobby.tscn")
@export var lobby_args : Array[String] = ["--mode lobby"]
var master_ip : String = "127.0.0.1"

var is_master : bool = false

func _ready() -> void:
	scope = Scope.Local
	if is_master:
		initiate_enet_server()
	else:
		initiate_enet_client(master_ip)
	
	
func launch_lobby() -> void:
	Main.main.output("Launching new lobby")
	Main.main.instance_launcher.launch_instance(lobby_args)
