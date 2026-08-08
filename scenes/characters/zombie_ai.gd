extends CharacterBody2D


enum State {
	IDLE,
	CHASE,
	SEARCH
}


@export_category("Vision")
@export var vision_distance: float = 250.0
@export var vertical_vision_limit: float = 90.0
@export var close_awareness_distance: float = 70.0
@export var chase_head_turn_distance: float = 220.0
@export var search_head_turn_interval: float = 0.8


@export_category("Movement")
@export var chase_speed: float = 80.0
@export var acceleration: float = 500.0


@export_category("Search")
@export var search_time: float = 3.0


var gravity: float = float(
	ProjectSettings.get_setting("physics/2d/default_gravity")
)

var facing_direction: float = 1.0
var head_direction: float = 1.0

var target: Node2D = null
var state: int = State.IDLE

var last_known_position: Vector2 = Vector2.ZERO
var search_timer: float = 0.0
var head_turn_timer: float = 0.0


@onready var sight_ray: RayCast2D = $Detection/SightRay


func _physics_process(delta: float) -> void:
	apply_gravity(delta)

	target = get_nearest_survivor()

	update_head_direction(delta)

	var can_see_target: bool = false

	if target != null:
		can_see_target = check_vision(target)

	update_state(can_see_target)

	match state:
		State.IDLE:
			handle_idle(delta)

		State.CHASE:
			handle_chase(delta)

		State.SEARCH:
			handle_search(delta)

	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func update_state(can_see_target: bool) -> void:
	if can_see_target and target != null:
		last_known_position = target.global_position

		if state != State.CHASE:
			print("Zombie spotted survivor.")

		state = State.CHASE
		search_timer = search_time
		return

	if state == State.CHASE:
		print("Zombie lost sight. Searching.")

		state = State.SEARCH
		search_timer = search_time
		head_turn_timer = 0.0


func handle_idle(delta: float) -> void:
	velocity.x = move_toward(
		velocity.x,
		0.0,
		acceleration * delta
	)


func handle_chase(delta: float) -> void:
	if target == null:
		state = State.SEARCH
		search_timer = search_time
		return

	var difference_x: float = (
		target.global_position.x - global_position.x
	)

	var direction: float = get_horizontal_direction(
		difference_x
	)

	if direction != 0.0:
		facing_direction = direction

	velocity.x = move_toward(
		velocity.x,
		direction * chase_speed,
		acceleration * delta
	)


func handle_search(delta: float) -> void:
	search_timer -= delta

	var difference_x: float = (
		last_known_position.x - global_position.x
	)

	var direction: float = get_horizontal_direction(
		difference_x
	)

	if absf(difference_x) > 8.0:
		facing_direction = direction

		velocity.x = move_toward(
			velocity.x,
			direction * chase_speed * 0.65,
			acceleration * delta
		)

	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * delta
		)

	if search_timer <= 0.0:
		print("Zombie gave up search.")

		state = State.IDLE
		head_direction = facing_direction


func update_head_direction(delta: float) -> void:
	if state == State.CHASE and target != null:
		var difference_x: float = (
			target.global_position.x - global_position.x
		)

		if absf(difference_x) <= chase_head_turn_distance:
			var new_direction: float = get_horizontal_direction(
				difference_x
			)

			if new_direction != 0.0:
				head_direction = new_direction

	elif state == State.SEARCH:
		head_turn_timer -= delta

		if head_turn_timer <= 0.0:
			head_direction *= -1.0
			head_turn_timer = search_head_turn_interval

	else:
		head_direction = facing_direction


func get_horizontal_direction(value: float) -> float:
	if value > 0.0:
		return 1.0

	if value < 0.0:
		return -1.0

	return 0.0


func get_nearest_survivor() -> Node2D:
	var survivors: Array[Node] = get_tree().get_nodes_in_group(
		"survivors"
	)

	var closest_survivor: Node2D = null
	var closest_distance: float = INF

	for survivor in survivors:
		if not survivor is Node2D:
			continue

		var survivor_2d: Node2D = survivor as Node2D

		var distance: float = global_position.distance_to(
			survivor_2d.global_position
		)

		if distance < closest_distance:
			closest_distance = distance
			closest_survivor = survivor_2d

	return closest_survivor


func check_vision(survivor: Node2D) -> bool:
	var offset: Vector2 = (
		survivor.global_position - global_position
	)

	var distance: float = offset.length()

	if distance > vision_distance:
		return false

	if absf(offset.y) > vertical_vision_limit:
		return false

	var survivor_is_very_close: bool = (
		distance <= close_awareness_distance
	)

	if not survivor_is_very_close:
		if head_direction > 0.0 and offset.x < 0.0:
			return false

		if head_direction < 0.0 and offset.x > 0.0:
			return false

	sight_ray.target_position = sight_ray.to_local(
		survivor.global_position
	)

	sight_ray.force_raycast_update()

	if not sight_ray.is_colliding():
		return false

	return sight_ray.get_collider() == survivor
