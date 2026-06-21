extends Panel

var lobby : Lobby:
	set(l):
		lobby = l
		if lobby:
			lobby.member_joined.connect(lobby_members_changed)
			lobby.member_left.connect(lobby_members_changed)
			lobby_members_changed()
			
			
func lobby_members_changed(_member = null) -> void:
	for child in $VBoxContainer/PlayerHolder.get_children():
		child.queue_free()
	if is_instance_valid(lobby):
		for member in lobby.members:
			var label = preload("res://multiplayer_template/menu/p2p_host_noray_menu/player_name_display.tscn").instantiate()
			label.text = member.name
			$VBoxContainer/PlayerHolder.add_child(label)
		
