class_name Lobby
extends Node

#class for a lobby, lobby is parent of the game scene and controls the game start etc

signal game_began
signal game_ended
signal received_external_address(ip : String, port : int)
signal accepted_into_lobby
signal authority_acknowleged(member_has_authority : bool)

signal member_joined(new_member : LobbyMember)
signal member_left

var stats : LobbyStats = LobbyStats.new()
var members : Array[LobbyMember] = []
var is_master : bool = false #the master lobby is the node on the lobby process of the server, the other lobby nodes are on the clients
var locked : bool = false:
	set(b):
		if b != locked:
			locked = b
			multiplayer.refuse_new_connections = b
			
var has_authority : bool = false

var game_manager : GameManager

#these variables will need be changed if any of those classes are extended with more variables, so that the correct deserializers will be used
static var lobby_stats_class = LobbyStats
static var lobby_member_class = LobbyMember
static var lobby_data_class = LobbyData

var game_manager_scene : PackedScene = preload("res://multiplayer_template/game_manager/game_manager.tscn")

func _ready() -> void:
	parse_args()
	
	#set components from config
	lobby_stats_class = Main.main.configuration.lobby_stats_script
	lobby_member_class = Main.main.configuration.lobby_member_script
	lobby_data_class = Main.main.configuration.lobby_data_script
	
	game_manager_scene = Main.main.configuration.game_manager_scene
	
	if is_master:
		(Main.mode as LobbyMode).launch_server()
		
	game_manager = game_manager_scene.instantiate()
	game_manager.lobby = self
	add_child(game_manager)
		
	Network.peer_disconnected.connect(_on_peer_disconnected)
	Network.server_disconnected.connect(_on_server_disconnected)
	
	stats.changed.connect(_on_stats_changed)
	
	
func parse_args() -> void:
	if Main.has_arg_option("--lobby-port"):
		stats.lobby_port = int(Main.get_arg_option_parameter("--lobby-port"))
		
	if Main.has_arg_option("--lobby-max-members"):
		stats.max_members = int(Main.get_arg_option_parameter("--lobby-max-members"))
		
	if Main.has_arg_option("--name"):
		stats.name = Main.get_arg_option_parameter("--name")


func serialize_to_lobby_data_dictionary() -> Dictionary:
	var serialized_members : Array = []
	for m in members:
		serialized_members.append(m.serialize_to_dictionary())
	return {"stats" : stats.serialize_to_dictionary(), "members": serialized_members}
	
	
func _on_stats_changed() -> void:
	if is_master:
		get_lobby_manager().submit_update()
		Main.output("Submitting stats update")
		update_remote_lobby_stats.rpc(stats.serialize_to_dictionary())
	
	
@rpc("reliable")
func update_remote_lobby_stats(new_stats : Dictionary) -> void:
	if not is_master:
		stats = LobbyStats.desirialize_from_dictionary(new_stats)
		Main.output("Received stats update")
	
	
func initiate_membership_request(member_dictionary : Dictionary) -> void:
	if not is_master:
		Main.output("Initiating member request")
		request_membership.rpc_id(1, member_dictionary)
	
	
@rpc("reliable", "any_peer")
func request_membership(member_dictionary : Dictionary) -> void:
	if is_master:
		Main.output("Received membership request")
		var new_member : LobbyMember = lobby_member_class.desirialize_from_dictionary(member_dictionary)
		new_member.id = multiplayer.get_remote_sender_id()
		if not has_member_with_id(new_member.id):
			if is_new_member_acceptable(new_member):
				register_new_member(new_member)
			else:
				Main.output("Rejecting a peer who wanted to become a member")
				multiplayer.multiplayer_peer.disconnect_peer(new_member.id)
		
		
func is_new_member_acceptable(_new_member : LobbyMember) -> bool:
	return stats.current_member_count < stats.max_members
	
	
func register_new_member(new_member : LobbyMember) -> void:
	members.append(new_member)
	stats.current_member_count = members.size() 
	#dont call get_lobby_manager().submit_update() because changings the stats has triggered this already
	update_remote_lobby_member_data.rpc(get_serialized_members())
	member_joined.emit(new_member)
	alert_accpetance.rpc_id(new_member.id)
	Main.output("Registering new member")
	
	
@rpc("reliable")
func alert_accpetance() -> void:
	if not is_master:
		trigger_inquire_authority()
		accepted_into_lobby.emit()
	
	
func remove_member_by_id(id : int) -> void:
	if not is_master:
		return
		
	var member_to_remove : LobbyMember = null
	for member in members:
		if member.id == id:
			member_to_remove = member
			break
	if member_to_remove != null:
		members.erase(member_to_remove)
		if multiplayer.get_peers().has(member_to_remove.id):
			multiplayer.multiplayer_peer.disconnect_peer(member_to_remove.id)
		get_lobby_manager().submit_update()
		member_left.emit(member_to_remove)
		update_remote_lobby_member_data.rpc(get_serialized_members())
		Main.output("Removed member with id: " + str(id))
	stats.current_member_count = members.size() 
	update_remote_lobby_member_data.rpc(get_serialized_members())
	
	 
@rpc("reliable")
func update_remote_lobby_member_data(new_member_data : Array) -> void:
	if not is_master:
		var old_members : Array[LobbyMember] = members.duplicate()
		members.clear()
		for member_dictionary in new_member_data:
			members.append(lobby_member_class.desirialize_from_dictionary(member_dictionary))
		
		#check if members left - ie check for old_members not in members
		var absent_members : Array[LobbyMember] = old_members.filter( \
				func(old_m): return not members.any( \
					func(new_m): return new_m.id == old_m.id))
		for absent_member in absent_members:
			Main.output("Member left: " + str(absent_member.serialize_to_dictionary()))
			member_left.emit(absent_member)
		
		#check if new members joined - ie check for members not in old members
		var new_members : Array[LobbyMember] = members.filter(\
				func(new_m): return not old_members.any( \
					func(old_m): return old_m.id == new_m.id))
		for new_member in new_members:
			if new_member.id != multiplayer.get_unique_id():
				Main.output("Member joined: " + str(new_member.serialize_to_dictionary()))
				member_joined.emit(new_member)


func clear_unregistered_peers() -> void: #if peer isn't a member, kick it. Could be called at start of game to clear any unauthorized connections, especially in private lobbies
	if is_master:
		for peer_id in multiplayer.get_peers():
			var peer_is_member : bool = false
			for member in members:
				if member.id == peer_id:
					peer_is_member = true
					break
			if not peer_is_member:
				multiplayer.multiplayer_peer.disconnect_peer(peer_id)
				Main.output("Removed peer who lacked membership")


func _on_peer_disconnected(id) -> void:
	if has_member_with_id(id):
		remove_member_by_id(id)
		
		
func _on_server_disconnected() -> void:
	if game_manager.is_game_loaded:
		end_game()
	
	
func get_serialized_members() -> Array[Dictionary]:
	var serialized_members : Array[Dictionary] = []
	for member in members:
		serialized_members.append(member.serialize_to_dictionary())
	return serialized_members
	

func get_lobby_manager() -> LobbyManager: #this function should only be called on the master lobby
	if Main.main.mode is LobbyMode:
		return (Main.main.mode as LobbyMode).lobby_manager
	else:
		push_error("get_lobby_manager called on a client lobby node which doesn't have a lobby manager")
		return null


func has_member_with_id(id : int) -> bool:
	var has_member : bool = false
	for member in members:
		if member.id == id:
			has_member = true
			break
	return has_member
	

#returns whether member has authority to boss lobby around (start/end game etc.)
func is_member_authority(member_id : int) -> bool:
	if not is_master:
		return false
	return members[0].id == member_id #default implementation gives authority to first client to join

	
func trigger_request_begin_game() -> void: #from client to server
	Main.output("Requesting that lobby begin game")
	request_begin_game.rpc_id(1)


@rpc("reliable", "any_peer")
func request_begin_game() -> void:
	if is_master:
		if is_member_authority(multiplayer.get_remote_sender_id()):
			trigger_begin_game()

	
func trigger_begin_game() -> void:
	if is_master:
		if game_manager.in_game:
			push_warning("trigger_begin_game() called on lobby while lobby is already in game")
			return
		begin_game.rpc()
	
	
@rpc("reliable", "call_local")
func begin_game() -> void:
	if game_manager.in_game:
		push_warning("begin_game() called on lobby while lobby is already in game")
		return
	Main.output("Beginning game")
	load_game()
	start_game()
	game_began.emit()
	
	
func load_game() -> void:
	Main.output("Loading game")
	game_manager.load_game()
	
	
func start_game() -> void:
	Main.output("Starting game")
	game_manager.start_game()
	
	
func trigger_request_end_game() -> void: #from client to server
	Main.output("Requesting that lobby end game")
	request_end_game.rpc_id(1)


@rpc("reliable", "any_peer")
func request_end_game() -> void:
	if is_master:
		if is_member_authority(multiplayer.get_remote_sender_id()):
			trigger_end_game()


func trigger_end_game() -> void:
	end_game.rpc()
	

@rpc("call_local")
func end_game() -> void:
	Main.output("Ending game")
	game_manager.end_game()
	game_ended.emit()
	
	
func trigger_request_external_address() -> void:
	if not is_master:
		request_external_address.rpc_id(1)
	
	
@rpc("any_peer", "reliable")
func request_external_address() -> void:
	if not is_master:
		return
	if not is_member_authority(multiplayer.get_remote_sender_id()):
		push_warning("Member without authority requested external address")
	if not Main.mode.get("upnp"):
		push_warning("Cannot get external address because mode does not have upnp")
		return
	var ip : String = Main.mode.upnp.external_ip
	var port : int = Main.mode.external_port
	deliver_external_address.rpc_id(multiplayer.get_remote_sender_id(), ip, port)

		
@rpc("reliable")
func deliver_external_address(ip : String, port : int) -> void:
	received_external_address.emit(ip, port)
	
	
func trigger_inquire_authority() -> void:
	if not is_master:
		inquire_authority.rpc_id(1)
	
	
@rpc("any_peer", "reliable")
func inquire_authority() -> void:
	if is_master:
		var member_has_authority : bool = is_member_authority(multiplayer.get_remote_sender_id())
		acknowledge_authority.rpc_id(multiplayer.get_remote_sender_id(), member_has_authority)
		
		
@rpc("reliable")
func acknowledge_authority(member_has_authority : bool) -> void:
	if not is_master:
		has_authority = member_has_authority
		authority_acknowleged.emit(member_has_authority)
		
		
func leave_lobby() -> void:
	if is_master:
		push_warning("Master lobby cannot leave lobby")
		return
	Network.close_peer()
	if game_manager.in_game:
		end_game()
	
	
