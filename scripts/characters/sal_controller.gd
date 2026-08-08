extends CharacterBody2D


@export_category("Movement")
@export var walk_speed: float = 120.0
@export var sprint_speed: float = 180.0
@export var crouch_speed: float = 65.0
@export var jump_velocity: float = -300.0
@export var acceleration: float = 900.0


@export_category("Stealth")
@export var crouch_noise: float = 0.2
@export var walk_noise: float = 0.5
@export var sprint_noise: float = 1.0


var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_crouching: bool = false
var is_sprinting: bool = false
var current_noise_level: float = 0.0
var facing_direction: float = 1.0


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_movement(delta)
	handle_jump()

	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func handle_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	is_crouching = Input.is_action_pressed("crouch") and is_on_floor()

	is_sprinting = (
		Input.is_action_pressed("sprint")
		and is_on_floor()
		and not is_crouching
		and abs(direction) > 0.01
	)

	var target_speed := walk_speed

	if is_crouching:
		target_speed = crouch_speed
		current_noise_level = crouch_noise

	elif is_sprinting:
		target_speed = sprint_speed
		current_noise_level = sprint_noise

	elif abs(direction) > 0.01:
		current_noise_level = walk_noise

	else:
		current_noise_level = 0.0

	if abs(direction) > 0.01:
		velocity.x = move_toward(
			velocity.x,
			direction * target_speed,
			acceleration * delta
		)

		facing_direction = sign(direction)

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


func get_noise_level() -> float:
	return current_noise_level
