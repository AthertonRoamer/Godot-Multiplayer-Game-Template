extends Control

var server_info_scene : PackedScene
var player_info_scene : PackedScene

var menus := []

enum menu_options {MENU1, HOST_MENU, CLIENT_MENU}

func _ready():
	server_info_scene = preload("res://menu/old_main_menu/server_info.tscn")
	player_info_scene = preload("res://menu/old_main_menu/player_info.tscn")
	
	Network.server_browser.found_server.connect(on_found_server)
	Network.server_browser.broadcast_failed.connect(on_broadcast_failed)
	Network.server_browser.listener_failed.connect(on_listener_failed)
	Network.server_failed.connect(on_server_failed)
	Network.player_info_updated.connect(on_player_info_updated)
	multiplayer.peer_connected.connect(on_client_count_changed)
	multiplayer.peer_disconnected.connect(on_client_count_changed)
	
	menus = [$Menu1, $HostMenu, $ClientMenu]
	set_menu(menu_options.MENU1)
	
	

func _on_host_pressed():
	#GameState.player_name = $Menu1/NameInput.text
	set_menu(menu_options.HOST_MENU)
	Network.initiate_server()


func _on_find_servers_pressed():
	#GameState.player_name = $Menu1/NameInput.text
	set_menu(menu_options.CLIENT_MENU)
	Network.server_browser.start_listening()
	

func _on_start_pressed():
	pass # Replace with function body.
	
	
func on_found_server(s_name, ip):
	print("Found server: " + s_name + " - " + ip)
	var s = server_info_scene.instantiate()
	s.ip = ip
	s.server_name = s_name
	$ClientMenu/Panel/ServerList.add_child(s)
	
	
func set_players_joined_label(n):
	$HostMenu/PlayersJoinedLabel.text = "Players joined: " + str(n)
	
	
func _on_host_back_pressed():
	Network.server_browser.stop_broadcast()
	Network.kill_peer()
	set_menu(menu_options.MENU1)
	for child in $HostMenu/Panel/PlayerList.get_children():
		child.queue_free()


func _on_client_back_pressed():
	Network.server_browser.stop_listening()
	Network.kill_peer()
	set_menu(menu_options.MENU1)
	for child in $ClientMenu/Panel/ServerList.get_children():
		child.queue_free()
		
		
func set_menu(n : int) -> void:
	if menus.size() > n:
		for i in menus:
			i.visible = false
		menus[n].visible = true
	#reset menu error messages
	$Menu1/ErrorOutput.text = ""
	$ClientMenu/ListeningStatus.text = "Listening for servers"
		
		
func on_client_count_changed(_id):
	set_players_joined_label(Network.client_count)
	
	
func on_server_failed():
	set_menu(menu_options.MENU1)
	$Menu1/ErrorOutput.text = "Failed to create server"
	
	
func on_broadcast_failed():
	Network.kill_peer()
	set_menu(menu_options.MENU1)
	$Menu1/ErrorOutput.text = "Server failed to broadcast"
	
	
func on_listener_failed():
	$ClientMenu/ListeningStatus.text = "Failed to listen for server"
	
	
func on_player_info_updated():
	for child in $HostMenu/Panel/PlayerList.get_children():
		child.queue_free()
	#for id in GameState.players_info:
		#if id != 1:
			#var p = player_info_scene.instantiate()
			#p.id = id
			#p.player_name = GameState.players_info[id].name
			#$HostMenu/Panel/PlayerList.add_child(p)


