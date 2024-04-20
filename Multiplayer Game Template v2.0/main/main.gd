class_name Main #entry point for project
extends Node

signal opening_mode(mode : Mode)
signal about_to_quit

#various elements of the system are exported here so each element can easily be switched out with other versions of that element
@export var menu_scene : PackedScene = preload("res://menu/main_menu/main_menu.tscn")
@export var lobby_manager_scene : PackedScene = preload("res://lobby_system/lobby_manager/lobby_manager.tscn")
@export var lobby_scene : PackedScene = preload("res://lobby_system/lobby/lobby.tscn")
@export var lobby_database_scene : PackedScene = preload("res://lobby_system/lobby_database/lobby_database.tscn")

var outputter : Output = Output.new() #module for debug output, by default if prints stuff normally
var instance_launcher : InstanceLauncher = InstanceLauncher.new()

static var main : Main #so any node can access main. It'd be nice if godot let the main scene be globally accessed like an autoload
var mode : Mode
var active_scene : Node
var arg_dictionary : Dictionary = {}

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	main = self
	load_menu()
	parse_arguments()
	if mode != null and mode.id != "none" and !mode.is_open:
		mode.open()
		opening_mode.emit(mode)
	
	
	
	
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
			if mode.id == new_mode.id:
				return
			mode.close()
		mode = new_mode
		mode.open()
		opening_mode.emit(mode)
		
		
func output(m) -> void:
	outputter.put(m)
	
	
func parse_arguments() -> void:
	var args  = OS.get_cmdline_args()
	for a in args:
		var arr = a.split(" ")
		arg_dictionary[arr[0]] = ""
		if arr.size() > 1:
			arg_dictionary[arr[0]] = arr[1]
	Main.main.output("arguments:   " + str(arg_dictionary))
	
	var modes = {"lobby" : LobbyMode.new(), "server" : DedicatedServerMode.new(), "client" : ClientMode.new()}
	if arg_dictionary.has("--mode") and modes.has(arg_dictionary["--mode"]):
		open_mode(modes[arg_dictionary["--mode"]])
		
		
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			about_to_quit.emit()
			get_tree().quit()
			
	
