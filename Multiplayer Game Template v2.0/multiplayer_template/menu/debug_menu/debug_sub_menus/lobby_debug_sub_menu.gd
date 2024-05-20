extends SubMenu

func _ready():
	Main.main.opening_mode.connect(_on_mode_changed)
	
	
func _on_mode_changed(m : Mode) -> void: 
	if m.id == "lobby":
		holder.open_menu("lobby")

func _on_set_lobby_name_pressed():
	var new_name : String = $VBoxContainer/VBoxContainer2/NameInput.text
	(Main.main.mode as LobbyMode).lobby.stats.name = new_name
	(Main.main.mode as LobbyMode).lobby_manager.submit_update()
	
	
func _on_back_pressed():
	Main.main.mode.close()
	holder.open_menu()



