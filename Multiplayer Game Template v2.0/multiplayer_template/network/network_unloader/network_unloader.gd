class_name NetworkUnloader
extends Node

##A node that can be used to unload connected nodes without triggering errors

signal cease_rpcs_request_received

var ceased_data : Dictionary = {}
var server_ceased : bool = false

func initiate_unload() -> void:
	if multiplayer.is_server():
		cease_rpcs.rpc()
	
	
@rpc("reliable", "call_local")
func cease_rpcs() -> void:
	cease_rpcs_request_received.emit()
	
	
func register_as_ceased() -> void:
	if multiplayer.is_server():
		server_ceased = true
	peer_ceased.rpc()
	
	
@rpc("any_peer", "reliable")
func peer_ceased() -> void:
	if multiplayer.is_server():
		ceased_data[multiplayer.get_remote_sender_id()] = true
		verify_cesation()
		
		
func verify_cesation() -> void:
	if multiplayer.is_server():
		if not server_ceased:
			return
		for peer in multiplayer.get_peers():
			if not ceased_data[peer]:
				return
		trigger_unload()
	
	
func trigger_unload() -> void:
	unload.rpc()
	
	
@rpc("reliable", "call_local")
func unload() -> void:
	get_parent().queue_free()
	

	
	
	
