extends DebugSubMenu

@export var ip_line_edit : LineEdit
@export var option_holder : Control
@export var ip_option_scene : PackedScene

func _ready() -> void:
	Network.server_browser.found_server.connect(_on_server_list_updated)


func _on_back_pressed():
	Main.main.mode.close()
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
