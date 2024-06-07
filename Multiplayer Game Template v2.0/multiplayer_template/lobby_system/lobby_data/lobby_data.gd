class_name LobbyData

#a container for the data of one lobby, used for sending all the data of a lobby over the network for the matchmaker
var lobby_id : int
var stats : LobbyStats
var members : Array[LobbyMember]

func serialize_to_dictionary() -> Dictionary:
	var serialized_members : Array = []
	for m in members:
		serialized_members.append(m.serialize_to_dictionary())
	return {"lobby_id": lobby_id, "stats" : stats.serialize_to_dictionary(), "members": serialized_members}


static func deserialize_from_dictionary(dict : Dictionary) -> LobbyData: #essentially a constructor for LobbyData from dictionary
	var lobby_data : LobbyData = Lobby.lobby_data_class.new()
	if dict.has("stats"): #load LobbyStats from dictionary
		lobby_data.stats = Lobby.lobby_stats_class.desirialize_from_dictionary(dict["stats"])
	if dict.has("members"): #load LobbyMember(s) from dictionary
		for member in dict["members"]:
			lobby_data.members.append(Lobby.lobby_member_class.desirialize_from_dictionary(member))
	if dict.has("lobby_id"): #load lobby id from dictionary
		lobby_data.lobby_id = dict["lobby_id"]
	return lobby_data
