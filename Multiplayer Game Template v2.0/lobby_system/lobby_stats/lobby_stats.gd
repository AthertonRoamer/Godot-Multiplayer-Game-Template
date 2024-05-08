class_name LobbyStats

#class for holding all non player specific data of the lobby
#this class will probably need to be extended to provide specific lobby stats for your game

var name : String = "LobbyName"
var lobby_port : int = 5000
var ip : String = ""


#if more variables are added to an extention of this class, these methods will need to be extended
#to include those values in the dictionary

func serialize_to_dictionary() -> Dictionary:
	return {"name" : name, "lobby_port": lobby_port, "ip": ip}
	
	
static func desirialize_from_dictionary(dict : Dictionary) -> LobbyStats: #effectively a constructor for this class
	var stats : LobbyStats = LobbyStats.new()
	if dict.has("name"):
		stats.name = dict["name"]
	if dict.has("lobby_port"):
		stats.lobby_port = dict["lobby_port"]
	if dict.has("ip"):
		stats.ip = dict["ip"]
	return stats
