class_name ClientMode
extends Mode

func _init() -> void:
	id = "client"


func open() -> void:
	super()
	Main.main.output("Opening client mode") 
	
	
func close() -> void:
	Network.close_peer()
	close_local_client()
	Main.main.output("Closing client mode")
	super()
	
	
func join_server(ip : String):
	Network.initiate_enet_client(ip)
	
	
func launch_local_client() -> void:
	Network.server_browser.start_listening()
	
	
func close_local_client() -> void:
	Network.server_browser.stop_listening()
	
	

