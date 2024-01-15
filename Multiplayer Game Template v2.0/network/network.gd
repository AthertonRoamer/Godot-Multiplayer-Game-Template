extends Node

#emitted when server creation failed
signal server_failed
#emitted when client creation failed
signal client_failed
#emitted when old peer is closed (even if it wasn't open before
signal peer_closed

#The following are shadows of signals emitted by MultiplayerAPI. They are emitted here to allow Netowrk to intercept them if necessary. (For instance Network might not emit peer_connected if a banned peer tried to connect)

#emitted on clients after successfully connecting to server
signal connected_to_server
#emitted on clients if connection to server failed
signal connection_failed
#emited when a new peer connects
signal peer_connected(id : int)
#emitted when peer disconnected
signal peer_disconnected(id : int)
#emitted on clients when disconnection with server occurs
signal server_disconnected


const PORT = 3000

@export var server_browser : ServerBrowser

var peer : ENetMultiplayerPeer
var is_server : bool = false
var client_count : int = 0


func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func initiate_server() -> void:
	close_peer()
	is_server = true
	peer = ENetMultiplayerPeer.new()
	var ok = peer.create_server(PORT)
	if ok != OK:
		print("Failed to create server. Error " + str(ok))
		server_failed.emit()
		return
	multiplayer.multiplayer_peer = peer
	print("Created server")
	
	
func initiate_local_server() -> void:
	initiate_server()
	server_browser.start_broadcast()


func initiate_client(ip : String) -> void:
	close_peer()
	is_server = false
	peer = ENetMultiplayerPeer.new()
	var ok = peer.create_client(ip, PORT)
	if ok != OK:
		print("Failed to create client. Error " + str(ok))
		client_failed.emit()
		return
	multiplayer.multiplayer_peer = peer
	print("Created client")
	
	
func close_peer() -> void:
	multiplayer.multiplayer_peer.close()
	is_server = false
	client_count = 0
	peer_closed.emit()
	
	
func _on_connected_to_server() -> void:
	print("Connected to server")
	connected_to_server.emit()
	

func _on_connection_failed() -> void:
	print("Connection to server failed")
	connection_failed.emit()
	
	
func _on_peer_connected(id) -> void:
	print("Peer connected with id: " + str(id))
	if is_server:
		client_count += 1
	peer_connected.emit()
	
	
func _on_peer_disconnected(id) -> void:
	print("Peer " + str(id) + " disconnected")
	if is_server:
		client_count -= 1
	peer_disconnected.emit()
	
	
func _on_server_disconnected():
	print("Disconnected with server")
	server_disconnected.emit()
	
	
