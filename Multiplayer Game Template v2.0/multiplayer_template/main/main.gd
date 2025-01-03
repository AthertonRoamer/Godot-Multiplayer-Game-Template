class_name Main #entry point for project
extends Node

signal opening_mode(mode : Mode)
signal about_to_quit

#the many components that make up this project structure are stored and can be set by using a configuration resource
@export var configuration : Configuration = preload("res://multiplayer_template/main/configuration/configurations/default_configuration.tres")

var menu_scene : PackedScene = preload("res://multiplayer_template/menu/main_menu/main_menu.tscn")
var lobby_manager_scene : PackedScene = preload("res://multiplayer_template/lobby_system/lobby_manager/lobby_manager.tscn")
var lobby_scene : PackedScene = preload("res://multiplayer_template/lobby_system/lobby/lobby.tscn")
var lobby_database_scene : PackedScene = preload("res://multiplayer_template/lobby_system/lobby_database/lobby_database.tscn")
var matchmaker_scene : PackedScene = preload("res://multiplayer_template/lobby_system/matchmaker/matchmaker.tscn")

static var outputter : Output = Output.new() #module for debug output, by default it prints stuff normally

static var main : Main #so any node can access main. It'd be nice if godot let the main scene be globally accessed like an autoload. What happens if an autoload is freed?
static var arg_dictionary : Dictionary = {}

static var instance_launcher : InstanceLauncher = InstanceLauncher.new()
static var mode : Mode
var active_scene : Node


static func output(m) -> void:
	outputter.put(m)
	
	
static func parse_arguments() -> void:
	var args = OS.get_cmdline_args()
	for a in args:
		var arr : Array = a.split(" ")
		arg_dictionary[arr[0]] = ""
		if arr.size() > 1:
			arg_dictionary[arr[0]] = arr[1]
	Main.output("arguments:   " + str(arg_dictionary))
	
	var modes = {"lobby" : LobbyMode.new(), "server" : DedicatedServerMode.new(), "client" : ClientMode.new()}
	
	var mode_parameter : String = get_arg_option_parameter("--mode")
	if modes.has(mode_parameter):
		open_mode(modes[mode_parameter])


static func has_arg_option(option : String) -> bool:
	return arg_dictionary.has(option)
	
	
static func get_arg_option_parameter(option : String) -> String:
	if has_arg_option(option):
		return arg_dictionary[option]
	else:
		return ""
		
		
static func open_mode(new_mode : Mode) -> void:
		if is_instance_valid(mode):
			if mode.id == new_mode.id:
				return
			mode.close()
		mode = new_mode
		mode.open()
		main.opening_mode.emit(mode)
	

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	main = self
	
	assert(configuration != null, "Configuration file in main is null")
	configuration.configure(self)
	
	#load components from configuration
	menu_scene = configuration.menu_scene
	lobby_manager_scene = configuration.lobby_manager_scene
	lobby_scene = configuration.lobby_scene
	lobby_database_scene = configuration.lobby_database_scene
	matchmaker_scene = configuration.matchmaker_scene
	
	Network.port = configuration.server_port
	Network.server_browser.listen_port = configuration.listen_port
	Network.server_browser.broadcast_port = configuration.broadcast_port

	load_menu()
	Main.parse_arguments()
	if Main.mode != null and Main.mode.id != "none" and !Main.mode.is_open:
		Main.mode.open()
		opening_mode.emit(mode)
		
		
func load_menu() -> void:
	clear_active_scene()
	var m = menu_scene.instantiate()
	add_child(m)
	active_scene = m


func clear_active_scene() -> void:
	if is_instance_valid(active_scene):
		active_scene.queue_free()
		
		
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			about_to_quit.emit()
			get_tree().quit()
			
	
