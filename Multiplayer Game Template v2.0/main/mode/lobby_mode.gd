class_name LobbyMode
extends Mode

func _init() -> void:
	id = "lobby"

func open() -> void:
	Main.main.output("Opening lobby mode")
	
	
func close() -> void:
	Main.main.output("Closing lobby mode")
