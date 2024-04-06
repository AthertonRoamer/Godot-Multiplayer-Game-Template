class_name DedicatedServerMode
extends Mode

func open() -> void:
	Main.main.output("Opening server mode")
	
	
func close() -> void:
	close_server()
	Main.main.output("Closing server mode")


func launch_server() -> void:
	Network.initiate_enet_server()
	
	
func launch_local_server() -> void:
	Network.initiate_local_enet_server()
	
	
func close_server() -> void:
	Network.close_peer()
	Network.server_browser.stop_broadcast()
