class_name LobbyMember

#class for holding the data of one member of a lobby and all the data needed for loading that player in the game
#each game will probably need to extend this class to add the custom player data
#this class is not intended to hold data that would change over the course of a game such as health etc 

var name : String = "Player name"
var id : int = 0

func serialize_to_dictionary() -> Dictionary:
	return {"name" : name, "id": id}
	
	
static func desirialize_from_dictionary(dict : Dictionary) -> LobbyMember: #effectively a constructor for this class
	var member : LobbyMember = LobbyMember.new()
	if dict.has("name"):
		member.name = dict["name"]
	if dict.has("id"):
		member.id = dict["id"]
	return member
