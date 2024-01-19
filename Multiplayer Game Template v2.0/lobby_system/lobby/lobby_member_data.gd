class_name LobbyMemberData
extends RefCounted

#class for the data of a member of a lobby

var id : int = 0
var name : String = "Player"


func serialize_to_dictionary() -> Dictionary:
	return {"id": id,
			"name": name}


#this function is effectively a constructor
static func deserialize_from_dictionary(data : Dictionary) -> LobbyMemberData:
	var lobby_member_data = LobbyMemberData.new()
	if data.has("id"):
		lobby_member_data.id = data.id 
	if data.has("name"):
		lobby_member_data.name = data.name
	return lobby_member_data
