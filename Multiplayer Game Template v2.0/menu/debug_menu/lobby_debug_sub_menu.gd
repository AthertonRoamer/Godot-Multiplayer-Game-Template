extends SubMenu

func _ready():
	Main.main.opening_mode.connect(_on_mode_changed)
	
	
func _on_mode_changed(m : Mode) -> void: 
	if m.id == "lobby":
		holder.open_menu("lobby")


func _on_back_pressed():
	Main.main.mode.close()
	holder.open_menu()
