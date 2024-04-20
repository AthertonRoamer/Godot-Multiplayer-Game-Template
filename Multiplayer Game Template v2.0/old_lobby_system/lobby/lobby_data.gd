#class_name LobbyData
extends RefCounted

#class for the static data of a lobby

var id : int = 0
var name : String = "Lobby Name"


func serialize_to_dictionary() -> Dictionary:
	return {"id": id,
			"name": name}


#this function is effectively a constructor
static func deserialize_from_dictionary(data : Dictionary) -> LobbyData:
	var lobby_data = LobbyData.new()
	if data.has("id"):
		lobby_data.id = data.id 
	if data.has("name"):
		lobby_data.name = data.name
	return lobby_data
