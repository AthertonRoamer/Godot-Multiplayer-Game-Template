extends Label

var lobby : Lobby
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	Main.main.opened_mode.connect(_on_opened_mode)
	
	
func _on_opened_mode(mode : Mode) -> void:
	if mode is P2PHostMode or mode is ClientMode:
		mode.lobby.member_joined.connect(_on_member_joined_or_left)
		mode.lobby.member_left.connect(_on_member_joined_or_left)
		lobby = mode.lobby
	
	
func _on_member_joined_or_left(_member) -> void:
	visible = not lobby.check_game_versions()
