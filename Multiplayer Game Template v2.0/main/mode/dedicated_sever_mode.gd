class_name DedicatedServerMode
extends Mode

func open() -> void:
	Main.main.output("Opening server mode")
	
	
func close() -> void:
	Network.close_peer()
	Main.main.output("Closing server mode")


func launch_server() -> void:
	Network.initiate_enet_server()
	
	
func launch_local_server() -> void:
	Network.initiate_local_enet_server()
