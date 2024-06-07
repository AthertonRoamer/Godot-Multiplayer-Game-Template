class_name LobbyDatabase
extends Node

signal data_changed

#a class for storing all the satellite lobbies data for access by either matchmaking system or clients

var data : Dictionary = {} : #dictionary is in form:  key is lobby id (int), value is lobby data (LobbyData)
	set(new_data):
		data = new_data
		data_changed.emit()
	
	
func update_data_from_dictionary(dict : Dictionary) -> void: #takes a dictionary, turns it into a LobbyData, and adds it to data
	var new_data : LobbyData = LobbyData.deserialize_from_dictionary(dict)
	data[new_data.lobby_id] = new_data
	data_changed.emit()
	
	
func remove_data_by_id(id : int) -> void:
	data.erase(id)
	data_changed.emit()
	
	
func get_data_by_id(id : int) -> LobbyData:
	if data.has(id):
		return data[id]
	else:
		return null
		
		
func get_data_as_array() -> Array[Dictionary]: #for sending entire block of data over network
	var result : Array[Dictionary] = []
	for datum in data.values():
		result.append(datum.serialize_to_dictionary())
	return result
	
	
func update_data_from_array(array : Array) -> void: #for recieving entire block of data from network
	data.clear()
	for datum in array:
		update_data_from_dictionary(datum)
	data_changed.emit()
	
	
func clear_data() -> void:
	data.clear()
	data_changed.emit()
		
		
func output_data() -> void:
	Main.output("All lobby data:")
	var dataset : Array = data.values()
	for datum in dataset:
		Main.output(str((datum as LobbyData).serialize_to_dictionary()))
	if dataset.is_empty():
		Main.output("<No lobbys>")

