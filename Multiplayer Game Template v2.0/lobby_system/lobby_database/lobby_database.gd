class_name LobbyDatabase
extends Node

#a class for storing all the satellite lobbies data for access by either matchmaking system or clients

var data : Dictionary = {} #dictionary is in form:  key is lobby id (int), value is lobby stats (LobbyStats)

#these variables can be changed, so that the correct deserializers will be used
var lobby_stats_class = LobbyStats
var lobby_member_class = LobbyMember
var lobby_data_class = LobbyData


func deserialize_lobby_data(dict : Dictionary) -> LobbyData:
	var lobby_data : LobbyData = lobby_data_class.new()
	if dict.has("stats"): #load LobbyStats from dictionary
		lobby_data.stats = lobby_stats_class.desirialize_from_dictionary(dict["stats"])
	if dict.has("members"): #load LobbyMember(s) from dictionary
		for member in dict["members"]:
			lobby_data.members.append(lobby_member_class.desirialize_from_dictionary(member))
	if dict.has("lobby_id"): #load lobby id from dictionary
		lobby_data.lobby_id = dict["lobby_id"]
	return lobby_data
	
	
func update_data_from_dictionary(dict : Dictionary) -> void:
	var new_data : LobbyData = deserialize_lobby_data(dict)
	data[new_data.lobby_id] = new_data
	
	
func remove_data_by_id(id : int) -> void:
	data.erase(id)
	
	
func get_data_by_id(id : int) -> LobbyData:
	if data.has(id):
		return data[id]
	else:
		return null

