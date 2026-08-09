extends Node2D


@export_category("Zombie Scene")
@export var default_zombie_scene: PackedScene


@export_category("Area Tuning")
@export var population_multiplier: float = 1.0
@export var initial_population_multiplier: float = 1.0
@export var spawn_interval_multiplier: float = 1.0
@export var minimum_spawn_distance: float = 260.0


@export_category("Testing Overrides")
@export var max_alive_override: int = 0
@export var initial_population_override: int = 0
@export var spawn_interval_override: float = 0.0


var spawn_points: Array[Marker2D] = []
var spawn_timer: float = 0.0

var random: RandomNumberGenerator = (
	RandomNumberGenerator.new()
)


func _ready() -> void:
	random.randomize()

	collect_spawn_points()

	call_deferred(
		"spawn_initial_population"
	)

	reset_spawn_timer()


func _process(delta: float) -> void:
	spawn_timer -= delta

	if spawn_timer > 0.0:
		return

	try_spawn_replacement()
	reset_spawn_timer()


func collect_spawn_points() -> void:
	spawn_points.clear()

	var children: Array[Node] = (
		$SpawnPoints.get_children()
	)

	for child: Node in children:
		if child is Marker2D:
			spawn_points.append(
				child as Marker2D
			)


func spawn_initial_population() -> void:
	if default_zombie_scene == null:
		return

	if spawn_points.is_empty():
		return

	var target_population: int = (
		get_initial_population()
	)

	var available_points: Array[Marker2D] = (
		get_eligible_spawn_points()
	)

	if available_points.is_empty():
		available_points = spawn_points.duplicate()

	available_points.shuffle()

	var spawned_count: int = 0

	while spawned_count < target_population:
		var point_index: int = (
			spawned_count
			% available_points.size()
		)

		var spawn_point: Marker2D = (
			available_points[point_index]
		)

		spawn_zombie_at(
			spawn_point.global_position
		)

		spawned_count += 1


func try_spawn_replacement() -> void:
	if get_alive_count() >= get_max_alive():
		return

	spawn_one_zombie()


func spawn_one_zombie() -> void:
	var spawn_point: Marker2D = (
		choose_spawn_point()
	)

	if spawn_point == null:
		return

	spawn_zombie_at(
		spawn_point.global_position
	)

func spawn_zombie_at(
	spawn_position: Vector2
) -> void:
	if default_zombie_scene == null:
		return

	var zombie: Node2D = (
		default_zombie_scene.instantiate()
		as Node2D
	)

	if zombie == null:
		return

	call_deferred(
		"finish_spawning_zombie",
		zombie,
		spawn_position
	)

func finish_spawning_zombie(
	zombie: Node2D,
	spawn_position: Vector2
) -> void:
	if zombie == null:
		return

	if not is_instance_valid(zombie):
		return

	var world: Node = get_parent()

	if world == null:
		zombie.queue_free()
		return

	world.add_child(zombie)

	zombie.global_position = spawn_position


func choose_spawn_point() -> Marker2D:
	if spawn_points.is_empty():
		return null

	var eligible_points: Array[Marker2D] = (
		get_eligible_spawn_points()
	)

	if eligible_points.is_empty():
		eligible_points = spawn_points.duplicate()

	var point_index: int = random.randi_range(
		0,
		eligible_points.size() - 1
	)

	return eligible_points[point_index]


func get_eligible_spawn_points() -> Array[Marker2D]:
	var survivor: Node2D = (
		get_reference_survivor()
	)

	var eligible_points: Array[Marker2D] = []

	if survivor == null:
		return spawn_points.duplicate()

	for point: Marker2D in spawn_points:
		var distance: float = (
			survivor.global_position.distance_to(
				point.global_position
			)
		)

		if distance >= minimum_spawn_distance:
			eligible_points.append(
				point
			)

	return eligible_points


func get_reference_survivor() -> Node2D:
	var survivors: Array[Node] = (
		get_tree().get_nodes_in_group(
			"survivors"
		)
	)

	for survivor: Node in survivors:
		if survivor is Node2D:
			return survivor as Node2D

	return null


func get_alive_count() -> int:
	return get_tree().get_nodes_in_group(
		"infected"
	).size()


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
				ZombieDirector
				.get_current_initial_population()
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
		ZombieDirector
			.get_current_spawn_interval()
			* spawn_interval_multiplier,
		0.25
	)


func reset_spawn_timer() -> void:
	spawn_timer = get_spawn_interval()
