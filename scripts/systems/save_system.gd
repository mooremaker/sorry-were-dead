extends Node


const SAVE_PATH: String = "user://last_save.json"


var pending_save_data: Dictionary = {}
var is_loading_save: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func has_last_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_checkpoint() -> bool:
	var current_scene: Node = get_tree().current_scene

	if current_scene == null:
		return false

	var scene_path: String = current_scene.scene_file_path

	if scene_path.is_empty():
		return false

	var player_entries: Array[Dictionary] = []
	var active_players: Array[Node] = get_tree().get_nodes_in_group(
		"active_players"
	)

	for player: Node in active_players:
		if not player is Node2D:
			continue

		var player_2d: Node2D = player as Node2D
		var entry: Dictionary = {
			"position_x": player_2d.global_position.x,
			"position_y": player_2d.global_position.y,
			"health": float(player.get("current_health")),
			"max_health": float(player.get("max_health"))
		}

		var pistol: Node = player.get_node_or_null(
			"WeaponSocket/Pistol"
		)

		if pistol != null:
			entry["pistol_ammo"] = int(
				pistol.get("ammo_in_magazine")
			)
			entry["pistol_reserve"] = int(
				pistol.get("reserve_ammo")
			)

		player_entries.append(entry)

	var data: Dictionary = {
		"version": 1,
		"scene_path": scene_path,
		"day": WorldClock.current_day,
		"hour": WorldClock.current_hour,
		"minute": WorldClock.current_minute,
		"players": player_entries
	}

	var file: FileAccess = FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if file == null:
		push_error("Could not open last-save file for writing.")
		return false

	file.store_string(
		JSON.stringify(data, "\t")
	)
	file.close()

	print("Checkpoint saved: ", SAVE_PATH)
	return true


func load_last_save() -> bool:
	if not has_last_save():
		return false

	var file: FileAccess = FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if file == null:
		return false

	var text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)

	if not parsed is Dictionary:
		push_error("Last-save data could not be parsed.")
		return false

	pending_save_data = parsed as Dictionary

	var scene_path: String = str(
		pending_save_data.get("scene_path", "")
	)

	if scene_path.is_empty():
		return false

	is_loading_save = true

	get_tree().paused = false
	WorldClock.resume_clock()
	GameState.reset_game_over()

	var change_error: Error = get_tree().change_scene_to_file(
		scene_path
	)

	if change_error != OK:
		push_error(
			"Could not load last-save scene: %s" % scene_path
		)
		is_loading_save = false
		return false

	call_deferred("restore_pending_after_scene_change")
	return true


func restore_pending_after_scene_change() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	restore_pending_save()


func restore_pending_save() -> void:
	if not is_loading_save:
		return

	if pending_save_data.is_empty():
		is_loading_save = false
		return

	WorldClock.set_time(
		int(pending_save_data.get("day", 1)),
		int(pending_save_data.get("hour", 6)),
		int(pending_save_data.get("minute", 0))
	)

	var player_data_value: Variant = pending_save_data.get(
		"players",
		[]
	)

	var player_entries: Array = []

	if player_data_value is Array:
		player_entries = player_data_value as Array

	var active_players: Array[Node] = get_tree().get_nodes_in_group(
		"active_players"
	)

	var restore_count: int = mini(
		active_players.size(),
		player_entries.size()
	)

	for index: int in range(restore_count):
		var player: Node = active_players[index]
		var entry_value: Variant = player_entries[index]

		if not entry_value is Dictionary:
			continue

		var entry: Dictionary = entry_value as Dictionary

		if player is Node2D:
			var player_2d: Node2D = player as Node2D
			player_2d.global_position = Vector2(
				float(entry.get("position_x", 0.0)),
				float(entry.get("position_y", 0.0))
			)

		player.set(
			"current_health",
			float(entry.get("health", 100.0))
		)
		player.set("is_down", false)

		var pistol: Node = player.get_node_or_null(
			"WeaponSocket/Pistol"
		)

		if pistol != null:
			if entry.has("pistol_ammo"):
				pistol.set(
					"ammo_in_magazine",
					int(entry["pistol_ammo"])
				)

			if entry.has("pistol_reserve"):
				pistol.set(
					"reserve_ammo",
					int(entry["pistol_reserve"])
				)

	pending_save_data.clear()
	is_loading_save = false

	WorldClock.resume_clock()
	GameState.reset_game_over()

	print("Last checkpoint restored.")
