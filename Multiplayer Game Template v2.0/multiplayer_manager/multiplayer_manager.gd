class_name MultiplayerManager #class for basic multiplayer system api
extends Node

func launch_server() -> void:
	Network.initiate_enet_server()
	
	
func launch_local_server() -> void:
	Network.initiate_local_enet_server()
		
		 
func launch_local_client() -> void:
	Network.server_browser.start_listening()
	
	
func join_server(ip : String):
	Network.initiate_enet_client(ip)

