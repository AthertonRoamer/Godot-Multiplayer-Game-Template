class_name Mode #this class handles the initializations and deinitializations of a mode of the project

var id : String = "none"

func open() -> void:
	pass #loads necessary resources but does not activate them	
	
	
func close() -> void:
	#unloads mode specific resources
	if Main.main.mode == self:
		Main.main.mode = null
