extends Node2D


const INVALID_SPAWN_POSITION := Vector2(
	99999999.0,
	99999999.0
)


@export_category("Zombie Scene")
@export var default_zombie_scene: PackedScene


@export_category("Random Spawn Area")

# Horizontal boundaries of this district.
# These values are relative to the ZombieSpawner node.
@export var spawn_min_x: float = 40.0
@export var spawn_max_x: float = 1160.0

# The spawner fires a physics ray downward to locate
# actual walkable ground.
@export var raycast_start_y: float = -300.0
@export var raycast_end_y: float = 800.0

# Raises the zombie slightly above the exact collision point
# so its feet/body don't spawn inside the ground.
@export var spawn_ground_offset: float = 20.0

# This must include the physics layer used by Ground.
@export_flags_2d_physics var ground_collision_mask: int = 1


@export_category("Spawn Safety")

# Never spawn a zombie this close to any survivor.
@export var minimum_player_distance: float = 280.0

# Prevent several zombies from appearing directly
# on top of one another.
@export var minimum_zombie_spacing: float = 45.0

# Replacement zombies normally appear outside the
# player's current camera view.
@export var replacements_must_be_offscreen: bool = true

# Adds some breathing room beyond the edge of the screen.
@export var offscreen_margin: float = 50.0

# Number of random positions to test before abandoning
# this spawn attempt.
@export var max_spawn_attempts: int = 40


@export_category("Area Tuning")
@export var population_multiplier: float = 1.0
@export var initial_population_multiplier: float = 1.0
@export var spawn_interval_multiplier: float = 1.0


@export_category("Testing Overrides")

# 0 means use ZombieDirector.
@export var max_alive_override: int = 0

# 0 means use ZombieDirector.
@export var initial_population_override: int = 0

# 0.0 means use ZombieDirector.
@export var spawn_interval_override: float = 0.0


var spawn_timer: float = 0.0

var random: RandomNumberGenerator = (
	RandomNumberGenerator.new()
)


func _ready() -> void:
	random.randomize()

	reset_spawn_timer()

	call_deferred(
		"prepare_initial_population"
	)


func prepare_initial_population() -> void:
	# Give Godot one physics frame so the level's
	# collision bodies are fully registered.
	await get_tree().physics_frame

	spawn_initial_population()


func _process(delta: float) -> void:
	spawn_timer -= delta

	if spawn_timer > 0.0:
		return

	try_spawn_replacement()

	reset_spawn_timer()


func spawn_initial_population() -> void:
	if default_zombie_scene == null:
		push_warning(
			"ZombieSpawner has no Default Zombie Scene assigned."
		)
		return

	var target_population: int = (
		get_initial_population()
	)

	var current_population: int = (
		get_alive_count()
	)

	var amount_to_spawn: int = maxi(
		target_population - current_population,
		0
	)

	var spawned: int = 0

	while spawned < amount_to_spawn:
		var success: bool = spawn_one_zombie(
			false
		)

		if not success:
			print(
				"ZombieSpawner could not find another valid initial position."
			)
			break

		spawned += 1


func try_spawn_replacement() -> void:
	if default_zombie_scene == null:
		return

	if get_alive_count() >= get_max_alive():
		return

	spawn_one_zombie(
		replacements_must_be_offscreen
	)


func spawn_one_zombie(
	require_offscreen: bool
) -> bool:
	var spawn_position: Vector2 = (
		find_valid_spawn_position(
			require_offscreen
		)
	)

	if spawn_position == INVALID_SPAWN_POSITION:
		return false

	return spawn_zombie_at(
		spawn_position
	)


func find_valid_spawn_position(
	require_offscreen: bool
) -> Vector2:
	var attempt: int = 0

	while attempt < max_spawn_attempts:
		attempt += 1

		var local_x: float = (
			random.randf_range(
				spawn_min_x,
				spawn_max_x
			)
		)

		var world_x: float = (
			global_position.x
			+ local_x
		)

		var ground_position: Vector2 = (
			find_ground_position(
				world_x
			)
		)

		if (
			ground_position
			== INVALID_SPAWN_POSITION
		):
			continue

		if not is_far_enough_from_survivors(
			ground_position
		):
			continue

		if not is_far_enough_from_zombies(
			ground_position
		):
			continue

		if (
			require_offscreen
			and not is_position_offscreen(
				ground_position
			)
		):
			continue

		return ground_position

	return INVALID_SPAWN_POSITION


func find_ground_position(
	world_x: float
) -> Vector2:
	var ray_start: Vector2 = Vector2(
		world_x,
		global_position.y
		+ raycast_start_y
	)

	var ray_end: Vector2 = Vector2(
		world_x,
		global_position.y
		+ raycast_end_y
	)

	var query: PhysicsRayQueryParameters2D = (
		PhysicsRayQueryParameters2D.create(
			ray_start,
			ray_end
		)
	)

	query.collision_mask = (
		ground_collision_mask
	)

	query.collide_with_bodies = true
	query.collide_with_areas = false

	query.exclude = (
		get_raycast_exclusions()
	)

	var space_state: PhysicsDirectSpaceState2D = (
		get_world_2d().direct_space_state
	)

	var result: Dictionary = (
		space_state.intersect_ray(
			query
		)
	)

	if result.is_empty():
		return INVALID_SPAWN_POSITION

	if not result.has("position"):
		return INVALID_SPAWN_POSITION

	var hit_position: Vector2 = (
		result["position"]
	)

	return Vector2(
		hit_position.x,
		hit_position.y
		- spawn_ground_offset
	)


func get_raycast_exclusions() -> Array[RID]:
	var exclusions: Array[RID] = []

	var survivors: Array[Node] = (
		get_tree().get_nodes_in_group(
			"survivors"
		)
	)

	for survivor: Node in survivors:
		if survivor is CollisionObject2D:
			var survivor_body: CollisionObject2D = (
				survivor as CollisionObject2D
			)

			exclusions.append(
				survivor_body.get_rid()
			)

	var zombies: Array[Node] = (
		get_tree().get_nodes_in_group(
			"infected"
		)
	)

	for zombie: Node in zombies:
		if zombie is CollisionObject2D:
			var zombie_body: CollisionObject2D = (
				zombie as CollisionObject2D
			)

			exclusions.append(
				zombie_body.get_rid()
			)

	return exclusions


func is_far_enough_from_survivors(
	spawn_position: Vector2
) -> bool:
	var survivors: Array[Node] = (
		get_tree().get_nodes_in_group(
			"survivors"
		)
	)

	for survivor: Node in survivors:
		if not survivor is Node2D:
			continue

		var survivor_2d: Node2D = (
			survivor as Node2D
		)

		var distance: float = (
			spawn_position.distance_to(
				survivor_2d.global_position
			)
		)

		if distance < minimum_player_distance:
			return false

	return true


func is_far_enough_from_zombies(
	spawn_position: Vector2
) -> bool:
	var zombies: Array[Node] = (
		get_tree().get_nodes_in_group(
			"infected"
		)
	)

	for zombie: Node in zombies:
		if not zombie is Node2D:
			continue

		var zombie_2d: Node2D = (
			zombie as Node2D
		)

		var distance: float = (
			spawn_position.distance_to(
				zombie_2d.global_position
			)
		)

		if distance < minimum_zombie_spacing:
			return false

	return true


func is_position_offscreen(
	spawn_position: Vector2
) -> bool:
	var camera: Camera2D = (
		get_viewport().get_camera_2d()
	)

	if camera == null:
		return true

	var viewport_size: Vector2 = (
		get_viewport_rect().size
	)

	var camera_center: Vector2 = (
		camera.get_screen_center_position()
	)

	var camera_zoom_x: float = maxf(
		absf(camera.zoom.x),
		0.001
	)

	var half_visible_width: float = (
		(viewport_size.x * 0.5)
		/ camera_zoom_x
	)

	var left_edge: float = (
		camera_center.x
		- half_visible_width
		- offscreen_margin
	)

	var right_edge: float = (
		camera_center.x
		+ half_visible_width
		+ offscreen_margin
	)

	if spawn_position.x < left_edge:
		return true

	if spawn_position.x > right_edge:
		return true

	return false


func spawn_zombie_at(
	spawn_position: Vector2
) -> bool:
	if default_zombie_scene == null:
		return false

	var zombie_instance: Node = (
		default_zombie_scene.instantiate()
	)

	if not zombie_instance is Node2D:
		zombie_instance.queue_free()

		push_warning(
			"Zombie scene root must inherit Node2D."
		)

		return false

	var zombie: Node2D = (
		zombie_instance as Node2D
	)

	var world: Node = get_parent()

	if world == null:
		zombie.queue_free()
		return false

	world.add_child(
		zombie
	)

	zombie.global_position = (
		spawn_position
	)

	return true


func get_alive_count() -> int:
	return (
		get_tree().get_nodes_in_group(
			"infected"
		).size()
	)


func get_max_alive() -> int:
	if max_alive_override > 0:
		return max_alive_override

	var scaled_max: int = int(
		round(
			float(
				ZombieDirector.get_current_max_alive()
			)
			* population_multiplier
		)
	)

	return maxi(
		scaled_max,
		1
	)


func get_initial_population() -> int:
	if initial_population_override > 0:
		return mini(
			initial_population_override,
			get_max_alive()
		)

	var scaled_initial: int = int(
		round(
			float(
				ZombieDirector.get_current_initial_population()
			)
			* initial_population_multiplier
		)
	)

	return clampi(
		scaled_initial,
		1,
		get_max_alive()
	)


func get_spawn_interval() -> float:
	if spawn_interval_override > 0.0:
		return spawn_interval_override

	return maxf(
		ZombieDirector.get_current_spawn_interval()
		* spawn_interval_multiplier,
		0.25
	)


func reset_spawn_timer() -> void:
	spawn_timer = (
		get_spawn_interval()
	)
