class_name LobbyStatsNoray
extends LobbyStats
#class for holding all non player specific data of the lobby
#this class will probably need to be extended to provide specific lobby stats for your game

#signal changed #emitted any time the stats are changed
#
##if this class is extended with more variables it is recommended to add setter functions which emit changed as done here
#var name : String = "LobbyName":
	#set(v):
		#name = v
		#changed.emit()
#var lobby_port : int = 5000:
	#set(v):
		#lobby_port = v
		#Main.output("Changing port")
		#changed.emit()
#var ip : String = "server":
	#set(v):
		#ip = v
		#changed.emit()
#var max_members : int = 10:
	#set(v):
		#max_members = v
		#changed.emit()
#var current_member_count : int = 0:
	#set(v):
		#current_member_count = v
		#changed.emit()
#var available_to_join : bool = true:
	#set(v):
		#available_to_join = v
		#changed.emit()
var game_id : String = "":
	set(v):
		Main.output("changing game id")
		game_id = v
		changed.emit()


#if more variables are added to an extention of this class, these methods will need to be extended
#to include those values in the dictionary

func serialize_to_dictionary() -> Dictionary:
	return {"name" : name, 
			"lobby_port": lobby_port, 
			"ip": ip,
			"max_members" : max_members,
			"current_member_count" : current_member_count,
			"available_to_join" : available_to_join,
			"game_id" : game_id,
			}


static func desirialize_from_dictionary(dict : Dictionary) -> LobbyStatsNoray: #effectively a constructor for this class
	var stats : LobbyStatsNoray = LobbyStatsNoray.new()
	if dict.has("name"):
		stats.name = dict["name"]
	if dict.has("lobby_port"):
		stats.lobby_port = dict["lobby_port"]
	if dict.has("ip"):
		stats.ip = dict["ip"]
	if dict.has("max_members"):
		stats.max_members = dict["max_members"]
	if dict.has("current_member_count"):
		stats.current_member_count = dict["current_member_count"]
	if dict.has("available_to_join"):
		stats.available_to_join = dict["available_to_join"]
	if dict.has("game_id"):
		stats.game_id = dict["game_id"]
	return stats
