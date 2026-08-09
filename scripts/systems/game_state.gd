extends Node


signal all_active_players_down
signal game_over_cleared


var game_over_active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func report_active_player_state_changed() -> void:
	call_deferred("check_all_active_players_down")


func check_all_active_players_down() -> void:
	if game_over_active:
		return

	var active_players: Array[Node] = get_tree().get_nodes_in_group(
		"active_players"
	)

	if active_players.is_empty():
		return

	for player: Node in active_players:
		if not bool(player.get("is_down")):
			return

	game_over_active = true
	all_active_players_down.emit()


func reset_game_over() -> void:
	game_over_active = false
	game_over_cleared.emit()
