class_name Lobby
extends Node

#class for a lobby, lobby is parent of the game scene and controls the game start etc

var stats : LobbyStats = LobbyStats.new()
var members : Array[LobbyMember] = []
var is_master : bool = false #the master lobby is the node on the lobby process of the server, the other lobby nodes are on the clients
var locked : bool = false:
	set(b):
		if b != locked:
			locked = b
			multiplayer.refuse_new_connections = b

var game_manager : GameManager

#these variables will need be changed if any of those classes are extended with more variables, so that the correct deserializers will be used
static var lobby_stats_class = LobbyStats
static var lobby_member_class = LobbyMember
static var lobby_data_class = LobbyData

static var game_manager_scene : PackedScene = preload("res://multiplayer_template/game_manager/game_manager.tscn")

func _ready() -> void:
	parse_args()
	
	if is_master:
		(Main.mode as LobbyMode).launch_server()
		
	game_manager = game_manager_scene.instantiate()
	add_child(game_manager)
		
	Network.peer_disconnected.connect(_on_peer_disconnected)
	
	stats.changed.connect(_on_stats_changed)
	
	
func parse_args() -> void:
	if Main.has_arg_option("--lobby-port"):
		stats.lobby_port = int(Main.get_arg_option_parameter("--lobby-port"))
		
	if Main.has_arg_option("--lobby-max-members"):
		stats.max_members = int(Main.get_arg_option_parameter("--lobby-max-members"))


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
	Main.output("Registering new member")
	
	
func remove_member_by_id(id : int) -> void:
	if is_master:
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
			update_remote_lobby_member_data.rpc(get_serialized_members())
			Main.output("Removed member with id: " + str(id))
	
	 
@rpc("reliable")
func update_remote_lobby_member_data(new_member_data : Array) -> void:
	if not is_master:
		members.clear()
		for member_dictionary in new_member_data:
			members.append(lobby_member_class.desirialize_from_dictionary(member_dictionary))


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
	
	
func load_game() -> void:
	Main.output("Loading game")
	game_manager.load_game()
	
	
func start_game() -> void:
	Main.output("Starting game")
	game_manager.start_game()
