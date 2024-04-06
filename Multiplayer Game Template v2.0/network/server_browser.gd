class_name ServerBrowser
extends Node
signal found_server(name : String, ip : String)
signal broadcast_failed
signal listener_failed

const LISTEN_PORT = 3001
const BROADCAST_PORT = 3002

var listener : PacketPeerUDP
var broadcaster : PacketPeerUDP

var broadcast_address := "127.0.0.255"
var broadcast_timer : Timer
var broadcast_data : Dictionary

var listening := false

var found_servers := []


func _process(_delta):
	if listening and listener.get_available_packet_count() > 0:
		var bytes = listener.get_packet()
		var server_ip = listener.get_packet_ip()
		if not found_servers.has(server_ip):
			found_servers.append(server_ip)
			var json_string = bytes.get_string_from_ascii()
			var data = JSON.parse_string(json_string)
			found_server.emit(data.server_name, server_ip)
			
			
func start_listening():
	listener = PacketPeerUDP.new()
	var ok = listener.bind(LISTEN_PORT)
	if ok != OK:
		Main.main.output("Failed to bind listener to listen port")
		listener_failed.emit()
		return
	listening = true
	Main.main.output("Bound listener to listen port")
	
	
func start_broadcast():
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	var ok = broadcaster.bind(BROADCAST_PORT)
	broadcast_address = get_broadcast_address()
	broadcaster.set_dest_address(broadcast_address, LISTEN_PORT)
	
	if ok != OK:
		Main.main.output("Failed to bind broadcaster to broadcast port")
		broadcast_failed.emit()
		return
		
	Main.main.output("Bound broadcaster to broadcast Port: " + str(BROADCAST_PORT) + " successfully!")
	$BroadcastTimer.start()
	
	
func stop_listening(): #this function may be called even if not listening
	listening = false
	listener = null
	found_servers = []
	Main.main.output("Stopped listening")
	
	
func stop_broadcast(): #this function may be called even if not broadcasting
	$BroadcastTimer.stop()
	broadcaster = null
	Main.main.output("Ended broadcast")
	

func _on_broadcast_timer_timeout():
	var json_data = JSON.stringify(broadcast_data)
	var packet = json_data.to_ascii_buffer()
	broadcaster.put_packet(packet)
	
	
func _exit_tree():
	stop_broadcast()
	stop_listening()
	
	
func get_broadcast_address() -> String:
	var address : String = "127.0.0.1"
	for interface in IP.get_local_interfaces():
		if interface.has("friendly") and interface.has("addresses"):
			if interface.friendly == "Wi-Fi":
				var addresses = interface.addresses
				address = str(addresses[addresses.size() - 1])
	return addr_to_broadcast_addr(address)
	
	
#replaces the last number in an ip address with 255
func addr_to_broadcast_addr(address : String) -> String:
	var parts = address.rsplit(".")
	if parts.size() >= 3:
		return parts[0] + "." + parts[1] + "." + parts[2] + ".255"
	else:
		return "127.0.0.255"
	
	
 
