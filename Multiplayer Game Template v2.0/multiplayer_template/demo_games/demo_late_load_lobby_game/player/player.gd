class_name DemoOnePlayer
extends CharacterBody2D

var player_name : String = "Player"
var id : int
@export var name_display : Label 

@export var local : bool = false #this player node is running on the player who controls it
@export var active : bool = false

@export var speed : int = 250

func _ready():
	name = str(id)
	name_display.text = player_name
	local = id == multiplayer.get_unique_id()
	
	
func _physics_process(_delta) -> void:
	if active and local:
		var vel : Vector2 = Vector2.ZERO
		if Input.is_action_pressed("ui_up"):
			vel.y -= 1
		if Input.is_action_pressed("ui_down"):
			vel.y += 1
		if Input.is_action_pressed("ui_left"):
			vel.x -= 1
		if Input.is_action_pressed("ui_right"):
			vel.x += 1
			
		velocity = vel * speed
		move_and_slide()
		update_position.rpc(position)
		
		
@rpc("any_peer")
func update_position(new_position : Vector2) -> void:
	position = new_position
