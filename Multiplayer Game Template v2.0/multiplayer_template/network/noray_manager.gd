class_name NorayManager
extends Node


var game_id : String = ""
var noray_server_ip : String = "159.89.237.170"
var custom_noray_server_ip : String = ""

func initiate_noray_server() -> void:
	Network.noray = true
	setup_host_noray_connection_signals()
	if await register_with_noray() != OK:
		return
	Network.initiate_enet_server()
	
	
	
func initiate_noray_client(g_id : String = game_id) -> void:
	Network.noray = true
	setup_client_noray_connection_signals()
	if await register_with_noray() != OK:
		Main.output("Register with noray failed")
		return
		
	#get game id
	game_id = g_id
	Noray.connect_nat(g_id)
	#Network.initiate_client()


func register_with_noray() -> Error:
	Main.output("registering with noray")
	var host = noray_server_ip
	if custom_noray_server_ip != "":
		host = custom_noray_server_ip
	var port = 8890
	var err = OK

	# Connect to noray
	Main.output("about to connect to host at " + host + ":" + str(port))
	err = await Noray.connect_to_host(host, port)
	if err != OK:
		Main.output("Error %s connecting to noray" % err)
		return err
	else:
		Main.output("No error connecting to noray")
	 
	# Register host
	Main.output("Registering host")
	Noray.register_host()
	Main.output("awaiting pid")
	await Noray.on_pid
	Main.output("got pid")
	game_id = Noray.oid
	Main.output("Noray game_id: " + str(game_id))

	# Register remote address
	# This is where noray will direct traffic
	Main.output("about to register remote")
	err = await Noray.register_remote()
	if err != OK:
		Main.output("Error %s registering with noray" % err) # Failed to register
		return err
		
	Main.output("Noray registration successful")
	Main.output("Noray local port: " + str(Noray.local_port))
	Network.port = Noray.local_port
	return OK
	
	
func _handle_noray_client_connect_request(address, port) -> void:
	Main.output("Noray host handle connect: %s:%s" % [address, port])
	var peer = multiplayer.multiplayer_peer as ENetMultiplayerPeer
	var err = await PacketHandshake.over_enet(peer.host, address, port)
	
	if err != OK:
		Main.output("Noray packet handshake failed %s" % err)


func _handle_nat_connect(address: String, port: int) -> Error:
	Main.output("Attempting to connect client via NAT: %s:%s" % [address, port])
	var err = await _handle_connect(address, port)
	if err != OK:
		Main.output("NAT connection failed from client, trying Relay instead...")
		Noray.connect_relay(game_id)
		return OK
	else:
		Main.output("NAT punchthrough successful!")
	return err


func _handle_relay_connect(address: String, port: int) -> Error:
	Main.output("Attempting to connect client via Relay: %s:%s" % [address, port])
	return await _handle_connect(address, port)


func _handle_connect(address: String, port: int) -> Error:
	Main.output("Client handle connect to %s:%s, Noray.localport: %s" % [address, port, Noray.local_port])
	
	# Do a handshake
	var udp = PacketPeerUDP.new()
	udp.bind(Noray.local_port)
	udp.set_dest_address(address, port)
	
	var err = await PacketHandshake.over_packet_peer(udp, 8)
	udp.close()
	
	if err != OK:
		Main.output("Client packet handshake failed %s" % err)
		return err
		
	# Connect to host
	Network.port = port
	Network.initiate_enet_client(address)
	return OK
	
	
func setup_host_noray_connection_signals():
	Noray.on_connect_nat.connect(_handle_noray_client_connect_request)
	Noray.on_connect_relay.connect(_handle_noray_client_connect_request)


func setup_client_noray_connection_signals():
	Noray.on_connect_nat.connect(_handle_nat_connect)
	Noray.on_connect_relay.connect(_handle_relay_connect)
