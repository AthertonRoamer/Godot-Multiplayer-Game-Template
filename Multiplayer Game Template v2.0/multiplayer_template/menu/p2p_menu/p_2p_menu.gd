extends Control

@export var sub_menu_holder : SubMenuHolder
@export var player_name_edit : LineEdit
@export var host_lobby_name_edit : LineEdit


func _on_host_pressed() -> void:
	sub_menu_holder.open_menu("setup_lobby")
	Main.open_mode(P2PHostMode.new())
	Main.mode.lobby.game_began.connect(_on_game_started)
	Main.mode.lobby.game_ended.connect(_on_game_ended)
	
	
func _on_start_lobby_button_pressed() -> void:
	Main.mode.my_member_data.name = player_name_edit.text
	Main.mode.lobby_name = host_lobby_name_edit.text
	Main.mode.launch_lobby()
	sub_menu_holder.open_menu("host")
	
	
func _on_host_close_lobby_button_pressed() -> void:
	Main.mode.shut_down_lobby()
	sub_menu_holder.open_menu("setup_lobby")
	
	
func _on_start_button_pressed() -> void:
	(Main.mode.lobby as Lobby).trigger_request_begin_game()


func _on_join_pressed() -> void:
	pass # Replace with function body.
	
	
func _on_game_started() -> void:
	visible = false
	
	
func _on_game_ended() -> void:
	visible = true


func _on_return_to_main_pressed() -> void:
	Main.mode.close()
	sub_menu_holder.open_menu()
