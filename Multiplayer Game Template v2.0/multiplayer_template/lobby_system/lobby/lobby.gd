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

#these variables will need be changed if any of those classes are extended with more variables, so that the correct deserializers will be used
static var lobby_stats_class = LobbyStats
static var lobby_member_class = LobbyMember
static var lobby_data_class = LobbyData

func _ready() -> void:
	parse_args()
	
	if is_master:
		(Main.mode as LobbyMode).launch_server()
		
	Network.peer_connected.connect(_on_peer_connected)
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
	
	
@rpc("reliable")
func update_remote_lobby_member_data(new_member_data : Array[Dictionary]) -> void:
	if not is_master:
		members.clear()
		for member_dictionary in new_member_data:
			members.append(lobby_member_class.desirialize_from_dictionary(member_dictionary))


func clear_unregistered_peers() -> void: #if peer is n't a member, kick it. Could be called at start of game to clear any unauthorized connections, especially in private lobbies
	if is_master:
		for peer_id in multiplayer.get_peers():
			var peer_is_member : bool = false
			for member in members:
				if member.id == peer_id:
					peer_is_member = true
					break
			if not peer_is_member:
				multiplayer.multiplayer_peer.disconnect_peer(peer_id)


func _on_peer_connected(_id) -> void:
	#stats.current_member_count = Network.client_count
	pass
	
	
func _on_peer_disconnected(_id) -> void:
	#stats.current_member_count = Network.client_count
	pass
	

func get_lobby_manager() -> LobbyManager: #this function should only be called on the master lobby
	if Main.main.mode is LobbyMode:
		return (Main.main.mode as LobbyMode).lobby_manager
	else:
		push_error("get_lobby_manager called on a client lobby node which doesn't have a lobby manager")
		return null
