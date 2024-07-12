extends SubMenu

@export var start_end_button : Button

func _ready():
	Main.main.opening_mode.connect(_on_mode_changed)
	
	
func _on_mode_changed(m : Mode) -> void: 
	if m.id == "lobby":
		holder.open_menu("lobby")


func _on_set_lobby_name_pressed():
	var new_name : String = $VBoxContainer/VBoxContainer2/NameInput.text
	(Main.mode as LobbyMode).lobby.stats.name = new_name
	(Main.mode as LobbyMode).lobby_manager.submit_update()
	
	
func _on_back_pressed():
	Main.mode.close()
	holder.open_menu()
	

var in_game : bool = false
func _on_start_end_pressed():
	if in_game:
		(Main.mode as LobbyMode).lobby.trigger_end_game()
		start_end_button.text = "Start Game"
	else:
		(Main.mode as LobbyMode).lobby.initiate_loading()
		start_end_button.text = "End Game"
	in_game = !in_game
