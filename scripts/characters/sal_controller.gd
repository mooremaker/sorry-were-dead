extends CharacterBody2D


@export_category("Movement")
@export var walk_speed: float = 120.0
@export var sprint_speed: float = 180.0
@export var crouch_speed: float = 65.0
@export var jump_velocity: float = -300.0
@export var acceleration: float = 900.0


@export_category("Health")
@export var max_health: float = 100.0
@export var hurt_flash_duration: float = 0.12


@export_category("Stealth")
@export var crouch_noise: float = 0.2
@export var walk_noise: float = 0.5
@export var sprint_noise: float = 1.0


@export_category("Footstep Noise")
@export var crouch_noise_radius: float = 40.0
@export var walk_noise_radius: float = 110.0
@export var sprint_noise_radius: float = 190.0
@export var footstep_interval: float = 0.35


var gravity: float = float(
	ProjectSettings.get_setting(
		"physics/2d/default_gravity"
	)
)

var current_health: float = 100.0
var is_down: bool = false

var is_crouching: bool = false
var is_sprinting: bool = false

var current_noise_level: float = 0.0
var facing_direction: float = 1.0
var footstep_timer: float = 0.0
var hurt_stun_timer: float = 0.0

var base_body_color: Color = Color.WHITE
var hurt_flash_tween: Tween = null


@onready var pistol: Node2D = (
	$WeaponSocket/Pistol
)

@onready var glaive: Node2D = (
	$WeaponSocket/PizzaCutterGlaive
)

@onready var body_visual: ColorRect = (
	$Visuals/BodyVisual
)


func _ready() -> void:
	add_to_group("survivors")
	add_to_group("active_players")

	current_health = max_health
	base_body_color = body_visual.color


func _physics_process(delta: float) -> void:
	if is_down:
		velocity.x = 0.0

		apply_gravity(delta)
		move_and_slide()

		return

	if hurt_stun_timer > 0.0:
		hurt_stun_timer = maxf(
			hurt_stun_timer - delta,
			0.0
		)

		apply_gravity(delta)

		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * 0.35 * delta
		)

		move_and_slide()

		return

	apply_gravity(delta)
	handle_movement(delta)
	handle_jump()
	handle_footstep_noise(delta)
	handle_weapon_input()

	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func handle_movement(delta: float) -> void:
	var direction: float = Input.get_axis(
		"move_left",
		"move_right"
	)

	is_crouching = (
		Input.is_action_pressed("crouch")
		and is_on_floor()
	)

	is_sprinting = (
		Input.is_action_pressed("sprint")
		and is_on_floor()
		and not is_crouching
		and absf(direction) > 0.01
	)

	var target_speed: float = walk_speed

	if is_crouching:
		target_speed = crouch_speed
		current_noise_level = crouch_noise

	elif is_sprinting:
		target_speed = sprint_speed
		current_noise_level = sprint_noise

	elif absf(direction) > 0.01:
		current_noise_level = walk_noise

	else:
		current_noise_level = 0.0

	if absf(direction) > 0.01:
		velocity.x = move_toward(
			velocity.x,
			direction * target_speed,
			acceleration * delta
		)

		facing_direction = direction

	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * delta
		)


func handle_jump() -> void:
	if (
		Input.is_action_just_pressed("jump")
		and is_on_floor()
		and not is_crouching
	):
		velocity.y = jump_velocity


func handle_footstep_noise(delta: float) -> void:
	if not is_on_floor():
		return

	if absf(velocity.x) < 5.0:
		footstep_timer = 0.0
		return

	footstep_timer -= delta

	if footstep_timer > 0.0:
		return

	var noise_radius: float = walk_noise_radius

	if is_crouching:
		noise_radius = crouch_noise_radius

	elif is_sprinting:
		noise_radius = sprint_noise_radius

	NoiseSystem.emit_noise(
		global_position,
		noise_radius,
		self
	)

	footstep_timer = footstep_interval


func handle_weapon_input() -> void:
	var mouse_position: Vector2 = (
		get_global_mouse_position()
	)

	var aim_direction: Vector2 = (
		mouse_position
		- pistol.global_position
	)

	pistol.set_aim_direction(
		aim_direction
	)

	glaive.set_aim_direction(
		aim_direction
	)

	if absf(aim_direction.x) > 5.0:
		if aim_direction.x > 0.0:
			facing_direction = 1.0
		else:
			facing_direction = -1.0

	if Input.is_action_just_pressed(
		"attack_primary"
	):
		pistol.try_fire()

	if (
		Input.is_action_just_pressed(
			"attack_secondary"
		)
		or Input.is_action_just_pressed(
			"melee"
		)
	):
		glaive.try_attack()

	if Input.is_action_just_pressed(
		"reload"
	):
		pistol.try_reload()


func get_noise_level() -> float:
	return current_noise_level


func take_damage(
	amount: float,
	hit_direction: Vector2 = Vector2.ZERO,
	knockback_strength: float = 0.0,
	stun_duration: float = 0.0
) -> void:
	if is_down:
		return

	current_health = maxf(
		current_health - amount,
		0.0
	)

	apply_damage_feedback(
		hit_direction,
		knockback_strength,
		stun_duration
	)

	print(
		"Sal took ",
		amount,
		" damage. Health: ",
		current_health
	)

	if current_health <= 0.0:
		become_down()


func apply_damage_feedback(
	hit_direction: Vector2,
	knockback_strength: float,
	stun_duration: float
) -> void:
	if hit_direction.length_squared() > 0.001:
		velocity += (
			hit_direction.normalized()
			* knockback_strength
		)

	hurt_stun_timer = maxf(
		hurt_stun_timer,
		stun_duration
	)

	if hurt_flash_tween != null:
		if hurt_flash_tween.is_valid():
			hurt_flash_tween.kill()

	body_visual.color = Color(
		1.0,
		0.3,
		0.3,
		1.0
	)

	hurt_flash_tween = create_tween()

	hurt_flash_tween.tween_property(
		body_visual,
		"color",
		base_body_color,
		hurt_flash_duration
	)


func become_down() -> void:
	if is_down:
		return

	is_down = true
	velocity = Vector2.ZERO
	current_noise_level = 0.0

	print("SAL IS DOWN.")

	GameState.report_active_player_state_changed()
