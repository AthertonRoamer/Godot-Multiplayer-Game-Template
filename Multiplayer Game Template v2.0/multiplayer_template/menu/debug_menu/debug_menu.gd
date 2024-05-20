class_name DebugMenu #this is a menu exposes more than would usually be shown to the user
extends Control

@export var debug_output_label : Label

var active_sub_menu : Control

func _ready() -> void:
	var output = LabelOutput.new()
	output.label = debug_output_label
	Main.main.outputter = output
	
	
