class_name NetworkManager #class for handling godot networking api
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


@export var port = 3000
@export var max_clients = 32

@export var server_browser : ServerBrowser

var peer : ENetMultiplayerPeer
var is_server : bool = false
var client_count : int = 0
var active_ip : String = ""

#global scope means this node changes the multiplayer_peer of the scene tree
#local scope means this node gives itself a new MultiplayerApi
#scope must be set before the node is added to the scen tree to have an effect
enum Scope {Global, Local}
@export var scope : Scope = Scope.Global


#if you extend this class, it is imperative that you include the current _ready() function
func _ready():
	if scope == Scope.Local:
		var multiplayerapi = SceneMultiplayer.new()
		get_tree().set_multiplayer(multiplayerapi, get_path()) #sets multiplayer for this node
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	
func set_scope(new_scope : Scope) -> void:
	if new_scope != scope:
		close_peer()
		match new_scope:
			Scope.Global:
				get_tree().set_multiplayer(get_tree().root.multiplayer, get_path())
			Scope.Local:
				var multiplayerapi = SceneMultiplayer.new()
				get_tree().set_multiplayer(multiplayerapi, get_path()) #sets multiplayer for this node
		multiplayer.connected_to_server.connect(_on_connected_to_server)
		multiplayer.connection_failed.connect(_on_connection_failed)
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		multiplayer.server_disconnected.connect(_on_server_disconnected)


func initiate_enet_server() -> void:
	close_peer()
	is_server = true
	peer = ENetMultiplayerPeer.new()
	var ok = peer.create_server(port, max_clients)
	if ok != OK:
		Main.main.output("Failed to create server. Error " + str(ok))
		server_failed.emit()
		return
	multiplayer.multiplayer_peer = peer
	Main.main.output("Created server")
	
	
func initiate_local_enet_server() -> void:
	initiate_enet_server()
	if is_instance_valid(server_browser):
		server_browser.start_broadcast()


func initiate_enet_client(ip : String) -> void:
	close_peer()
	is_server = false
	peer = ENetMultiplayerPeer.new()
	var ok = peer.create_client(ip, port)
	if ok != OK:
		Main.main.output("Failed to create client. Error " + str(ok))
		client_failed.emit()
		return
	active_ip = ip
	multiplayer.multiplayer_peer = peer
	Main.main.output("Created client")
	
	
func close_peer() -> void:
	multiplayer.multiplayer_peer.close()
	is_server = false
	client_count = 0
	active_ip = ""
	peer_closed.emit()
	
	
func _on_connected_to_server() -> void:
	Main.main.output("Connected to server")
	connected_to_server.emit()
	

func _on_connection_failed() -> void:
	Main.main.output("Connection to server failed")
	connection_failed.emit()
	
	
func _on_peer_connected(id) -> void:
	Main.main.output("Peer connected with id: " + str(id))
	if is_server:
		client_count += 1
	peer_connected.emit(id)
	
	
func _on_peer_disconnected(id) -> void:
	Main.main.output("Peer " + str(id) + " disconnected")
	if is_server:
		client_count -= 1
	peer_disconnected.emit(id)
	
	
func _on_server_disconnected():
	Main.main.output("Disconnected with server")
	server_disconnected.emit()
	
	
