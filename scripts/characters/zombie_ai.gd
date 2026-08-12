extends CharacterBody2D


const ITEM_PICKUP_SCENE: PackedScene = preload(
	"res://scenes/items/item_pickup.tscn"
)


enum State {
	IDLE,
	INVESTIGATE,
	CHASE,
	SEARCH
}


@export_category("Vision")
@export var vision_distance: float = 250.0
@export var vertical_vision_limit: float = 90.0
@export var close_awareness_distance: float = 70.0
@export var chase_head_turn_distance: float = 220.0
@export var search_head_turn_interval: float = 0.8


@export_category("Health")
@export var max_health: float = 100.0
@export var hit_flash_duration: float = 0.10
@export var death_feedback_duration: float = 0.45


@export_category("Movement")
@export var chase_speed: float = 80.0
@export var investigate_speed: float = 55.0
@export var acceleration: float = 500.0


@export_category("Wandering")
@export var wander_speed: float = 28.0
@export var wander_radius: float = 90.0
@export var wander_move_time_min: float = 0.8
@export var wander_move_time_max: float = 2.0
@export var wander_pause_time_min: float = 0.5
@export var wander_pause_time_max: float = 1.8


@export_category("Search")
@export var search_time: float = 3.0
@export var investigate_arrival_distance: float = 12.0


@export_category("Attack")
@export var attack_range: float = 42.0
@export var attack_damage: float = 20.0
@export var attack_cooldown: float = 1.2
@export var attack_knockback: float = 75.0
@export var attack_stun: float = 0.12


@export_category("Loot")

# Overall chance that a zombie drops anything.
# 0.45 = 45%.
@export_range(0.0, 1.0, 0.05)
var loot_drop_chance: float = 0.45

# Moves the dropped item slightly downward from
# the zombie's center.
@export var loot_drop_offset_y: float = 8.0


var gravity: float = float(
	ProjectSettings.get_setting(
		"physics/2d/default_gravity"
	)
)


var facing_direction: float = 1.0
var head_direction: float = 1.0

var target: Node2D = null
var state: int = State.IDLE

var last_known_position: Vector2 = Vector2.ZERO

var search_timer: float = 0.0
var head_turn_timer: float = 0.0
var attack_timer: float = 0.0
var hit_stun_timer: float = 0.0

var current_health: float = 100.0
var is_dead: bool = false

var base_body_color: Color = Color.WHITE
var hit_flash_tween: Tween = null


var wander_origin: Vector2 = Vector2.ZERO
var wander_direction: float = 1.0
var wander_timer: float = 0.0
var wander_is_moving: bool = false


var wander_random: RandomNumberGenerator = (
	RandomNumberGenerator.new()
)

var loot_random: RandomNumberGenerator = (
	RandomNumberGenerator.new()
)


@onready var sight_ray: RayCast2D = (
	$Detection/SightRay
)

@onready var debug_state: Label = (
	$Visuals/DebugState
)

@onready var body_visual: ColorRect = (
	$Visuals/BodyVisual
)

@onready var visuals: Node2D = (
	$Visuals
)

@onready var collision_shape: CollisionShape2D = (
	$CollisionShape2D
)


func _ready() -> void:
	NoiseSystem.noise_emitted.connect(
		_on_noise_emitted
	)

	current_health = max_health
	base_body_color = body_visual.color

	add_to_group("infected")

	wander_random.randomize()
	loot_random.randomize()

	call_deferred(
		"initialize_wandering"
	)


func initialize_wandering() -> void:
	wander_origin = global_position

	start_wander_pause()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	apply_gravity(delta)

	attack_timer = maxf(
		attack_timer - delta,
		0.0
	)

	if hit_stun_timer > 0.0:
		hit_stun_timer = maxf(
			hit_stun_timer - delta,
			0.0
		)

		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * 0.3 * delta
		)

		move_and_slide()

		return

	target = get_nearest_survivor()

	var can_see_target: bool = false

	if target != null:
		can_see_target = check_vision(
			target
		)

	update_vision_state(
		can_see_target
	)

	update_head_direction(
		delta
	)

	match state:
		State.IDLE:
			handle_idle(
				delta
			)

		State.INVESTIGATE:
			handle_investigate(
				delta
			)

		State.CHASE:
			handle_chase(
				delta
			)

		State.SEARCH:
			handle_search(
				delta
			)

	update_debug_state()

	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


# ---------------------------------------------------------
# IDLE / WANDERING
# ---------------------------------------------------------

func handle_idle(delta: float) -> void:
	wander_timer -= delta

	if wander_timer <= 0.0:
		if wander_is_moving:
			start_wander_pause()
		else:
			start_wander_move()

	if not wander_is_moving:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * delta
		)

		return

	var distance_from_origin: float = (
		global_position.x
		- wander_origin.x
	)

	if distance_from_origin > wander_radius:
		wander_direction = -1.0

	elif distance_from_origin < -wander_radius:
		wander_direction = 1.0

	if is_on_wall():
		wander_direction *= -1.0

	if wander_direction != 0.0:
		facing_direction = wander_direction
		head_direction = wander_direction

	velocity.x = move_toward(
		velocity.x,
		wander_direction * wander_speed,
		acceleration * delta
	)


func start_wander_move() -> void:
	wander_is_moving = true

	if wander_random.randf() < 0.5:
		wander_direction = -1.0
	else:
		wander_direction = 1.0

	wander_timer = wander_random.randf_range(
		wander_move_time_min,
		wander_move_time_max
	)


func start_wander_pause() -> void:
	wander_is_moving = false

	wander_timer = wander_random.randf_range(
		wander_pause_time_min,
		wander_pause_time_max
	)


# ---------------------------------------------------------
# INVESTIGATING SOUNDS
# ---------------------------------------------------------

func handle_investigate(
	delta: float
) -> void:
	var difference_x: float = (
		last_known_position.x
		- global_position.x
	)

	var direction: float = (
		get_horizontal_direction(
			difference_x
		)
	)

	if (
		absf(difference_x)
		> investigate_arrival_distance
	):
		if direction != 0.0:
			facing_direction = direction
			head_direction = direction

		velocity.x = move_toward(
			velocity.x,
			direction * investigate_speed,
			acceleration * delta
		)

	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * delta
		)

		print(
			"Zombie reached the sound. Searching."
		)

		state = State.SEARCH
		search_timer = search_time
		head_turn_timer = 0.0


# ---------------------------------------------------------
# CHASE / ATTACK
# ---------------------------------------------------------

func handle_chase(
	delta: float
) -> void:
	if target == null:
		state = State.SEARCH
		search_timer = search_time

		return

	var offset: Vector2 = (
		target.global_position
		- global_position
	)

	var distance: float = (
		offset.length()
	)

	var direction: float = (
		get_horizontal_direction(
			offset.x
		)
	)

	if direction != 0.0:
		facing_direction = direction
		head_direction = direction

	if distance <= attack_range:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * delta
		)

		try_attack_target()

		return

	velocity.x = move_toward(
		velocity.x,
		direction * chase_speed,
		acceleration * delta
	)


func try_attack_target() -> void:
	if target == null:
		return

	if attack_timer > 0.0:
		return

	if not target.has_method(
		"take_damage"
	):
		return

	var attack_offset: Vector2 = (
		target.global_position
		- global_position
	)

	if attack_offset.length() > attack_range:
		return

	sight_ray.target_position = (
		sight_ray.to_local(
			target.global_position
		)
	)

	sight_ray.force_raycast_update()

	if not sight_ray.is_colliding():
		return

	if sight_ray.get_collider() != target:
		return

	target.call(
		"take_damage",
		attack_damage,
		attack_offset.normalized(),
		attack_knockback,
		attack_stun
	)

	attack_timer = attack_cooldown

	print(
		"Zombie attacked survivor!"
	)


# ---------------------------------------------------------
# SEARCH
# ---------------------------------------------------------

func handle_search(
	delta: float
) -> void:
	search_timer -= delta

	var difference_x: float = (
		last_known_position.x
		- global_position.x
	)

	var direction: float = (
		get_horizontal_direction(
			difference_x
		)
	)

	if absf(difference_x) > 8.0:
		facing_direction = direction

		velocity.x = move_toward(
			velocity.x,
			direction * investigate_speed,
			acceleration * delta
		)

	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * delta
		)

	if search_timer <= 0.0:
		print(
			"Zombie gave up search."
		)

		state = State.IDLE

		head_direction = facing_direction

		# Begin wandering around wherever the zombie
		# finished its search.
		wander_origin = global_position

		start_wander_pause()


# ---------------------------------------------------------
# VISION
# ---------------------------------------------------------

func update_vision_state(
	can_see_target: bool
) -> void:
	if (
		can_see_target
		and target != null
	):
		last_known_position = (
			target.global_position
		)

		if state != State.CHASE:
			print(
				"Zombie spotted survivor!"
			)

		state = State.CHASE
		search_timer = search_time

		return

	if state == State.CHASE:
		print(
			"Zombie lost sight. Searching."
		)

		state = State.SEARCH
		search_timer = search_time
		head_turn_timer = 0.0


func check_vision(
	survivor: Node2D
) -> bool:
	var offset: Vector2 = (
		survivor.global_position
		- global_position
	)

	var distance: float = (
		offset.length()
	)

	if distance > vision_distance:
		return false

	if (
		absf(offset.y)
		> vertical_vision_limit
	):
		return false

	var survivor_is_very_close: bool = (
		distance
		<= close_awareness_distance
	)

	if not survivor_is_very_close:
		if (
			head_direction > 0.0
			and offset.x < 0.0
		):
			return false

		if (
			head_direction < 0.0
			and offset.x > 0.0
		):
			return false

	sight_ray.target_position = (
		sight_ray.to_local(
			survivor.global_position
		)
	)

	sight_ray.force_raycast_update()

	if not sight_ray.is_colliding():
		return false

	return (
		sight_ray.get_collider()
		== survivor
	)


func update_head_direction(
	delta: float
) -> void:
	if (
		state == State.CHASE
		and target != null
	):
		var difference_x: float = (
			target.global_position.x
			- global_position.x
		)

		if (
			absf(difference_x)
			<= chase_head_turn_distance
		):
			var new_direction: float = (
				get_horizontal_direction(
					difference_x
				)
			)

			if new_direction != 0.0:
				head_direction = new_direction

	elif state == State.INVESTIGATE:
		var difference_x: float = (
			last_known_position.x
			- global_position.x
		)

		var new_direction: float = (
			get_horizontal_direction(
				difference_x
			)
		)

		if new_direction != 0.0:
			head_direction = new_direction

	elif state == State.SEARCH:
		head_turn_timer -= delta

		if head_turn_timer <= 0.0:
			head_direction *= -1.0

			head_turn_timer = (
				search_head_turn_interval
			)

	else:
		head_direction = facing_direction


# ---------------------------------------------------------
# HEARING
# ---------------------------------------------------------

func _on_noise_emitted(
	noise_position: Vector2,
	noise_radius: float,
	source: Node2D
) -> void:
	if is_dead:
		return

	if source == self:
		return

	var distance_to_noise: float = (
		global_position.distance_to(
			noise_position
		)
	)

	if distance_to_noise > noise_radius:
		return

	if state == State.CHASE:
		return

	last_known_position = noise_position
	state = State.INVESTIGATE

	var direction: float = (
		get_horizontal_direction(
			noise_position.x
			- global_position.x
		)
	)

	if direction != 0.0:
		head_direction = direction

	print(
		"Zombie heard something!"
	)


# ---------------------------------------------------------
# SURVIVOR TARGETING
# ---------------------------------------------------------

func get_nearest_survivor() -> Node2D:
	var survivors: Array[Node] = (
		get_tree().get_nodes_in_group(
			"survivors"
		)
	)

	var closest_survivor: Node2D = null
	var closest_distance: float = INF

	for survivor: Node in survivors:
		if not survivor is Node2D:
			continue

		var survivor_2d: Node2D = (
			survivor as Node2D
		)

		var survivor_is_down: bool = bool(
			survivor_2d.get(
				"is_down"
			)
		)

		if survivor_is_down:
			continue

		var distance: float = (
			global_position.distance_to(
				survivor_2d.global_position
			)
		)

		if distance < closest_distance:
			closest_distance = distance
			closest_survivor = survivor_2d

	return closest_survivor


func get_horizontal_direction(
	value: float
) -> float:
	if value > 0.0:
		return 1.0

	if value < 0.0:
		return -1.0

	return 0.0


# ---------------------------------------------------------
# DEBUG STATE
# ---------------------------------------------------------

func update_debug_state() -> void:
	match state:
		State.IDLE:
			debug_state.text = ""

		State.INVESTIGATE:
			debug_state.text = "?"

		State.CHASE:
			debug_state.text = "!"

		State.SEARCH:
			debug_state.text = "..."


# ---------------------------------------------------------
# DAMAGE / HIT FEEDBACK
# ---------------------------------------------------------

func take_damage(
	amount: float,
	hit_direction: Vector2 = Vector2.ZERO,
	knockback_strength: float = 0.0,
	stun_duration: float = 0.0
) -> void:
	if is_dead:
		return

	current_health = maxf(
		current_health - amount,
		0.0
	)

	apply_hit_feedback(
		hit_direction,
		knockback_strength,
		stun_duration
	)

	print(
		"Zombie took ",
		amount,
		" damage. Health: ",
		current_health
	)

	if current_health <= 0.0:
		die()


func apply_hit_feedback(
	hit_direction: Vector2,
	knockback_strength: float,
	stun_duration: float
) -> void:
	if (
		hit_direction.length_squared()
		> 0.001
	):
		velocity += (
			hit_direction.normalized()
			* knockback_strength
		)

	hit_stun_timer = maxf(
		hit_stun_timer,
		stun_duration
	)

	if hit_flash_tween != null:
		if hit_flash_tween.is_valid():
			hit_flash_tween.kill()

	body_visual.color = Color(
		1.0,
		0.25,
		0.2,
		1.0
	)

	hit_flash_tween = create_tween()

	hit_flash_tween.tween_property(
		body_visual,
		"color",
		base_body_color,
		hit_flash_duration
	)


# ---------------------------------------------------------
# RANDOM LOOT
# ---------------------------------------------------------

func try_drop_loot() -> void:
	# First roll:
	# Does this zombie drop anything?
	if loot_random.randf() > loot_drop_chance:
		return

	# Second roll:
	# Which item drops?
	var roll: float = (
		loot_random.randf()
		* 100.0
	)

	var item_id: String = "scrap"
	var display_name: String = "Scrap"
	var amount: int = 1

	var item_color: Color = Color(
		0.9,
		0.75,
		0.2,
		1.0
	)

	# 35% of successful drops
	if roll < 35.0:
		item_id = "scrap"
		display_name = "Scrap"

		amount = loot_random.randi_range(
			1,
			3
		)

		item_color = Color(
			0.9,
			0.75,
			0.2,
			1.0
		)

	# 25%
	elif roll < 60.0:
		item_id = "9mm_ammo"
		display_name = "9mm Ammo"

		amount = loot_random.randi_range(
			2,
			6
		)

		item_color = Color(
			0.85,
			0.2,
			0.15,
			1.0
		)

	# 18%
	elif roll < 78.0:
		item_id = "bottled_water"
		display_name = "Bottled Water"
		amount = 1

		item_color = Color(
			0.2,
			0.55,
			1.0,
			1.0
		)

	# 14%
	elif roll < 92.0:
		item_id = "canned_food"
		display_name = "Canned Food"
		amount = 1

		item_color = Color(
			0.95,
			0.5,
			0.15,
			1.0
		)

	# 8%
	else:
		item_id = "medicine"
		display_name = "Medicine"
		amount = 1

		item_color = Color(
			0.2,
			0.85,
			0.35,
			1.0
		)

	spawn_loot_pickup(
		item_id,
		display_name,
		amount,
		item_color
	)


func spawn_loot_pickup(
	item_id: String,
	display_name: String,
	amount: int,
	item_color: Color
) -> void:
	var pickup_instance: Node = (
		ITEM_PICKUP_SCENE.instantiate()
	)

	if not pickup_instance is Node2D:
		pickup_instance.queue_free()
		return

	var pickup: Node2D = (
		pickup_instance as Node2D
	)

	var world: Node = get_parent()

	if world == null:
		pickup.queue_free()
		return

	if pickup.has_method(
		"setup_item"
	):
		pickup.call(
			"setup_item",
			item_id,
			display_name,
			amount,
			item_color
		)

	world.add_child(
		pickup
	)

	pickup.global_position = (
		global_position
		+ Vector2(
			0.0,
			loot_drop_offset_y
		)
	)

	print(
		"Zombie dropped ",
		amount,
		" x ",
		item_id
	)


# ---------------------------------------------------------
# DEATH
# ---------------------------------------------------------

func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO

	remove_from_group(
		"infected"
	)

	collision_shape.set_deferred(
		"disabled",
		true
	)

	debug_state.text = ""

	# Roll the loot table once when the zombie dies.
	try_drop_loot()

	var fall_rotation: float = 1.35

	if facing_direction > 0.0:
		fall_rotation = -1.35

	var death_tween: Tween = (
		create_tween()
	)

	death_tween.set_parallel(
		true
	)

	death_tween.tween_property(
		visuals,
		"rotation",
		fall_rotation,
		death_feedback_duration
	)

	death_tween.tween_property(
		visuals,
		"modulate:a",
		0.0,
		death_feedback_duration
	)

	death_tween.set_parallel(
		false
	)

	death_tween.tween_callback(
		Callable(
			self,
			"queue_free"
		)
	)

	print(
		"Zombie died."
	)
