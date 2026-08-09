extends Node2D


@export_category("Damage")
@export var damage: float = 40.0
@export var attack_reach: float = 42.0
@export var knockback_strength: float = 105.0
@export var hit_stun_duration: float = 0.18


@export_category("Attack")
@export var attack_cooldown: float = 0.55


@export_category("Noise")
@export var melee_noise_radius: float = 65.0


@export_category("Prototype Feedback")
@export var swing_visual_duration: float = 0.13
@export var swing_arc_radians: float = 1.35


var attack_timer: float = 0.0
var swing_visual_timer: float = 0.0
var aim_direction: Vector2 = Vector2.RIGHT


@onready var hit_cast: ShapeCast2D = $HitCast


func _ready() -> void:
	exclude_survivor()


func _process(delta: float) -> void:
	attack_timer = maxf(
		attack_timer - delta,
		0.0
	)

	if swing_visual_timer > 0.0:
		swing_visual_timer = maxf(
			swing_visual_timer - delta,
			0.0
		)
		queue_redraw()


func _draw() -> void:
	if swing_visual_timer <= 0.0:
		return

	var center_angle: float = aim_direction.angle()
	var half_arc: float = swing_arc_radians * 0.5

	draw_arc(
		Vector2.ZERO,
		attack_reach * 0.78,
		center_angle - half_arc,
		center_angle + half_arc,
		14,
		Color(0.95, 0.95, 0.88, 0.95),
		2.0,
		false
	)

	draw_line(
		aim_direction * 10.0,
		aim_direction * attack_reach,
		Color(0.8, 0.82, 0.75, 0.65),
		1.0,
		false
	)


func set_aim_direction(direction: Vector2) -> void:
	if direction.length_squared() <= 0.001:
		return

	aim_direction = direction.normalized()
	hit_cast.target_position = (
		aim_direction * attack_reach
	)


func try_attack() -> void:
	if attack_timer > 0.0:
		return

	attack_timer = attack_cooldown
	swing_visual_timer = swing_visual_duration
	queue_redraw()

	hit_cast.force_shapecast_update()

	var hit_zombies: Array[Node] = []
	var collision_count: int = hit_cast.get_collision_count()

	for index: int in range(collision_count):
		var collider: Object = hit_cast.get_collider(index)

		if not collider is Node:
			continue

		var hit_node: Node = collider as Node

		if not hit_node.is_in_group("infected"):
			continue

		if not hit_node.has_method("take_damage"):
			continue

		if hit_zombies.has(hit_node):
			continue

		hit_node.call(
			"take_damage",
			damage,
			aim_direction,
			knockback_strength,
			hit_stun_duration
		)

		hit_zombies.append(hit_node)

	NoiseSystem.emit_noise(
		global_position,
		melee_noise_radius,
		self
	)

	print(
		"GLAIVE SWING! Hit ",
		hit_zombies.size(),
		" infected."
	)


func exclude_survivor() -> void:
	var node: Node = get_parent()

	while node != null:
		if node is CollisionObject2D:
			hit_cast.add_exception(
				node as CollisionObject2D
			)
			return

		node = node.get_parent()
