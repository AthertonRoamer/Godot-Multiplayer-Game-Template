class_name Mode #this class handles the initializations and deinitializations of a mode of the project

var id : String = "none"
var is_open : bool = false

func open() -> void:
	is_open = true #loads necessary resources but does not activate them	
	
	
func close() -> void:
	#unloads mode specific resources
	is_open = false
	if Main.main.mode == self:
		Main.main.mode = null
