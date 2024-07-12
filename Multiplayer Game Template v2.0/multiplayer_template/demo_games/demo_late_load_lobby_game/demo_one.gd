class_name DemoOne
extends Node2D

var players : Array = []
var first_pos : Vector2 = Vector2(100, 100)
@export var player_scene : PackedScene 

func _ready() -> void:
	if get_parent() is GameManager:
		for member in get_parent().lobby.members:
			load_player(member)
		if get_parent().lobby.is_master:
			visible = false
	
	
func start() -> void:
	for player in players:
		player.active = true


func end() -> void:
	queue_free()
	
	
func load_player(member : LobbyMember) -> void:
	var new_player : DemoOnePlayer = player_scene.instantiate()
	players.append(new_player)
	new_player.id = member.id
	new_player.player_name = member.name
	new_player.position = Vector2(first_pos.x + 100 * (players.size() - 1), first_pos.y)
	add_child(new_player)
