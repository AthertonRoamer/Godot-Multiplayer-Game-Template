class_name LobbyStatsGame
extends LobbyStatsNoray

var selected_map_index: int = -1:
	set(v):
		selected_map_index = v
		changed.emit()


func serialize_to_dictionary() -> Dictionary:
	var dict = super.serialize_to_dictionary()
	dict["selected_map_index"] = selected_map_index
	return dict


static func desirialize_from_dictionary(dict: Dictionary) -> LobbyStatsGame:
	var stats = LobbyStatsGame.new()
	if dict.has("name"): stats.name = dict["name"]
	if dict.has("lobby_port"): stats.lobby_port = dict["lobby_port"]
	if dict.has("ip"): stats.ip = dict["ip"]
	if dict.has("max_members"): stats.max_members = dict["max_members"]
	if dict.has("current_member_count"): stats.current_member_count = dict["current_member_count"]
	if dict.has("available_to_join"): stats.available_to_join = dict["available_to_join"]
	if dict.has("game_id"): stats.game_id = dict["game_id"]
	if dict.has("selected_map_index"): stats.selected_map_index = dict["selected_map_index"]
	return stats
