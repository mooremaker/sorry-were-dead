extends Node


signal pressure_changed(
	day: int,
	max_alive: int,
	spawn_interval: float
)


@export_category("Day Scaling")
@export var day_one_max_alive: int = 8
@export var extra_alive_per_day: float = 0.55
@export var maximum_alive_cap: int = 24

@export_category("Initial Population")
@export var day_one_initial_population: int = 6
@export var extra_initial_per_day: float = 0.25
@export var maximum_initial_population: int = 12

@export_category("Replacement Pressure")
@export var day_one_spawn_interval: float = 3.5
@export var interval_reduction_per_day: float = 0.08
@export var minimum_spawn_interval: float = 1.4

@export_category("Future Zombie Mix Hooks")
@export var runner_unlock_day: int = 7
@export var special_unlock_day: int = 15


func _ready() -> void:
	WorldClock.day_changed.connect(_on_day_changed)


func get_current_max_alive() -> int:
	return get_max_alive_for_day(
		WorldClock.current_day
	)


func get_max_alive_for_day(day: int) -> int:
	var safe_day: int = maxi(day, 1)
	var day_bonus: int = int(
		floor(
			float(safe_day - 1)
			* extra_alive_per_day
		)
	)

	return mini(
		day_one_max_alive + day_bonus,
		maximum_alive_cap
	)


func get_current_initial_population() -> int:
	return get_initial_population_for_day(
		WorldClock.current_day
	)


func get_initial_population_for_day(day: int) -> int:
	var safe_day: int = maxi(day, 1)
	var day_bonus: int = int(
		floor(
			float(safe_day - 1)
			* extra_initial_per_day
		)
	)

	return mini(
		day_one_initial_population + day_bonus,
		maximum_initial_population
	)


func get_current_spawn_interval() -> float:
	return get_spawn_interval_for_day(
		WorldClock.current_day
	)


func get_spawn_interval_for_day(day: int) -> float:
	var safe_day: int = maxi(day, 1)
	var reduction: float = (
		float(safe_day - 1)
		* interval_reduction_per_day
	)

	return maxf(
		day_one_spawn_interval - reduction,
		minimum_spawn_interval
	)


func get_runner_pressure() -> float:
	if WorldClock.current_day < runner_unlock_day:
		return 0.0

	return minf(
		0.05 + float(
			WorldClock.current_day - runner_unlock_day
		) * 0.01,
		0.25
	)


func get_special_pressure() -> float:
	if WorldClock.current_day < special_unlock_day:
		return 0.0

	return minf(
		0.02 + float(
			WorldClock.current_day - special_unlock_day
		) * 0.005,
		0.12
	)


func _on_day_changed(day: int) -> void:
	var max_alive: int = get_max_alive_for_day(day)
	var spawn_interval: float = get_spawn_interval_for_day(day)

	pressure_changed.emit(
		day,
		max_alive,
		spawn_interval
	)

	print(
		"Zombie pressure updated. Day ",
		day,
		" | Max alive: ",
		max_alive,
		" | Replacement interval: ",
		spawn_interval
	)
