extends SubMenu

@export var ip_line_edit : LineEdit
@export var option_holder : Control
@export var ip_option_scene : PackedScene
@export var lobby_option_scene : PackedScene
@export var lobby_option_display : Control
@export var name_line_edit : LineEdit

func _ready() -> void:
	Network.server_browser.found_server.connect(_on_server_list_updated)
	
	
func opened() -> void:
	if not (Main.mode as ClientMode).matchmaker.database.data_changed.is_connected(_on_lobby_data_changed):
		(Main.mode as ClientMode).matchmaker.database.data_changed.connect(_on_lobby_data_changed)
	#var menu_root : Control = get_parent().get_parent()
	(Main.mode as ClientMode).lobby.game_began.connect(Main.main.active_scene._on_game_started)
	(Main.mode as ClientMode).lobby.game_ended.connect(Main.main.active_scene._on_game_ended)
	

func _on_back_pressed():
	Main.mode.close()
	ip_line_edit.text = "127.0.0.1"
	holder.open_menu()


func _on_join_pressed():
	var ip = ip_line_edit.text
	if Main.mode is ClientMode:
		(Main.mode as ClientMode).join_server(ip)
		
		
func _on_ip_option_pressed(option : IPOption) -> void:
	ip_line_edit.text = option.ip
	
	
func _on_server_list_updated(_a, _b) -> void:
	update_ip_options()
	
	
func update_ip_options() -> void:
	for child in option_holder.get_children():
		child.queue_free()
	for ip in Network.server_browser.found_servers:
		add_ip_option(ip)
	
	
func add_ip_option(ip : String) -> void:
	var o : IPOption = ip_option_scene.instantiate()
	o.ip = ip
	o.selected.connect(_on_ip_option_pressed)
	option_holder.add_child(o)


func _on_print_lobby_data_pressed():
	(Main.mode as ClientMode).matchmaker.database.output_data()
	
	
func _on_lobby_data_changed() -> void:
	update_lobby_options()
	
	
func update_lobby_options() -> void:
	var data : Array = (Main.mode as ClientMode).matchmaker.database.data.values()
	for child in lobby_option_display.get_children():
		child.queue_free()
	for item in data:
		var option : LobbyOption = lobby_option_scene.instantiate()
		option.lobby_data = item
		option.selected.connect(_on_lobby_option_selected)
		lobby_option_display.add_child(option)
		

func _on_lobby_option_selected(lobby_data : LobbyData) -> void:
	var member : LobbyMember = Lobby.lobby_member_class.new()
	member.name = name_line_edit.text
	(Main.mode as ClientMode).join_lobby(lobby_data, member)
