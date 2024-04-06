class_name ClientMode
extends Mode

func open() -> void:
	Main.main.output("Opening client mode")
	
	
func close() -> void:
	Network.close_peer()
	Main.main.output("Closing client mode")
	
	
func join_server(ip : String):
	Network.initiate_enet_client(ip)
