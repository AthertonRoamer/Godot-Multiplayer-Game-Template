extends SubMenu

@export var ip_line_edit : LineEdit
@export var option_holder : Control
@export var ip_option_scene : PackedScene
@export var lobby_option_scene : PackedScene
@export var lobby_option_display : Control

func _ready() -> void:
	Network.server_browser.found_server.connect(_on_server_list_updated)
	
	
func opened() -> void:
	(Main.main.mode as ClientMode).matchmaker.database.data_changed.connect(_on_lobby_data_changed)


func _on_back_pressed():
	Main.main.mode.close()
	ip_line_edit.text = "127.0.0.1"
	holder.open_menu()


func _on_join_pressed():
	var ip = ip_line_edit.text
	if Main.main.mode is ClientMode:
		(Main.main.mode as ClientMode).join_server(ip)
		
		
func _on_option_pressed(option : IPOption) -> void:
	ip_line_edit.text = option.ip
	
	
func _on_server_list_updated(_a, _b) -> void:
	update_options()
	
	
func update_options() -> void:
	for child in option_holder.get_children():
		child.queue_free()
	for ip in Network.server_browser.found_servers:
		add_option(ip)
	
	
func add_option(ip : String) -> void:
	var o : IPOption = ip_option_scene.instantiate()
	o.ip = ip
	o.selected.connect(_on_option_pressed)
	option_holder.add_child(o)


func _on_print_lobby_data_pressed():
	(Main.main.mode as ClientMode).matchmaker.database.output_data()
	
	
func _on_lobby_data_changed() -> void:
	update_lobby_options()
	
	
func update_lobby_options() -> void:
	var data : Array = (Main.main.mode as ClientMode).matchmaker.database.data.values()
	for child in lobby_option_display.get_children():
		child.queue_free()
	for item in data:
		var option : LobbyOption = lobby_option_scene.instantiate()
		option.lobby_data = item
		lobby_option_display.add_child(option)
		
