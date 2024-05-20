extends HBoxContainer

var ip : String

var server_name : String

var attempting_to_join := false
var joined := false

func _ready():
	$ServerName.text = server_name
	$Ip.text = ip
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.server_disconnected.connect(on_disconnected_to_server)


func _on_join_server_pressed():
	if not joined: 
		#join server
		Network.initiate_client(ip)
		attempting_to_join = true
	else:
		#leave server
		Network.kill_peer()
		joined = false
		$JoinServer.text = "Join"
		
		
func on_connected_to_server():
	if attempting_to_join:
		attempting_to_join = false
		joined = true
		$JoinServer.text = "Leave"
	else:
		$JoinServer.text = "Join"
		joined = false
		
		
func on_disconnected_to_server():
	if joined:
		joined = false
		$JoinServer.text = "Join"
		Network.kill_peer()
		
		
