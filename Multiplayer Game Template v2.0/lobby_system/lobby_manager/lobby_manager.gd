class_name LobbyManager
extends NetworkManager

@export var lobby_scene : PackedScene = preload("res://lobby_system/lobby/lobby.tscn")
@export var lobby_args : Array[String] = ["--mode lobby"]
var master_ip : String = "127.0.0.1"

var is_master : bool = false


func _ready() -> void:
	Main.main.about_to_quit.connect(_on_about_to_quit)
	scope = Scope.Local
	if is_master:
		initiate_enet_server()
	else:
		multiplayer.connection_failed.connect(_on_connection_to_server_failed)
		initiate_enet_client(master_ip)
		
	
func launch_lobby() -> void:
	Main.main.output("Launching new lobby")
	Main.main.instance_launcher.launch_instance(lobby_args)
	
	
func _on_connection_to_server_failed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST) #if satellite lobby fails to reach main lobby manager, kill the instance
	
	
@rpc("reliable") func kill_lobby() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	
	
func _on_about_to_quit() -> void:
	if is_master:
		kill_lobby.rpc()
		OS.delay_msec(250) #delay allows time for remote procedural call to take place (I think - I know that without the delay the lobby satellites won't close
		

