class_name Main #entry point for project
extends Node

@export var menu_scene : PackedScene = preload("res://menu/main_menu/main_menu.tscn")

static var main : Main #any node can access main, It'd be nice if godot let the main scene be globally accessed like an autoload

var active_scene : Node

var mode : Mode

var outputter : Output = Output.new() #module for debug output, by default if prints stuff normally

func _ready() -> void:
	main = self
	load_menu()
	
	
func load_menu() -> void:
	clear_active_scene()
	var m = menu_scene.instantiate()
	add_child(m)
	active_scene = m
	
	
func clear_active_scene() -> void:
	if is_instance_valid(active_scene):
		active_scene.queue_free()
		
		
func open_mode(new_mode : Mode) -> void:
	if is_instance_valid(mode):
		mode.close()
	mode = new_mode
	mode.open()
		
		
func output(m) -> void:
	outputter.put(m)
	
	
