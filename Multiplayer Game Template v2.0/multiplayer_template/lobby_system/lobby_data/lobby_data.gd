class_name LobbyData

#a container for the data of one lobby
var lobby_id : int
var stats : LobbyStats
var members : Array[LobbyMember]

func serialize_to_dictionary() -> Dictionary:
	var serialized_members : Array = []
	for m in members:
		serialized_members.append(m.serialize_to_dictionary())
	return {"lobby_id": lobby_id, "stats" : stats.serialize_to_dictionary(), "members": serialized_members}
