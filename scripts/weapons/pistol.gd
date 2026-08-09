extends Node2D


@export_category("Damage")
@export var damage: float = 25.0
@export var weapon_range: float = 500.0
@export var knockback_strength: float = 55.0
@export var hit_stun_duration: float = 0.10


@export_category("Ammo")
@export var magazine_size: int = 8
@export var reserve_ammo: int = 24
@export var reload_time: float = 1.2


@export_category("Fire")
@export var fire_cooldown: float = 0.25
@export var gunshot_noise_radius: float = 650.0


@export_category("Prototype Feedback")
@export var tracer_duration: float = 0.055
@export var tracer_width: float = 1.0


var ammo_in_magazine: int = 8
var fire_timer: float = 0.0
var reload_timer: float = 0.0
var feedback_timer: float = 0.0

var is_reloading: bool = false
var aim_direction: Vector2 = Vector2.RIGHT
var tracer_end: Vector2 = Vector2.RIGHT * 500.0


@onready var bullet_ray: RayCast2D = $BulletRay
@onready var muzzle: Marker2D = $Muzzle


func _ready() -> void:
	ammo_in_magazine = magazine_size
	exclude_survivor_from_bullet_ray()


func _process(delta: float) -> void:
	fire_timer = maxf(
		fire_timer - delta,
		0.0
	)

	if feedback_timer > 0.0:
		feedback_timer = maxf(
			feedback_timer - delta,
			0.0
		)
		queue_redraw()

	if is_reloading:
		reload_timer -= delta

		if reload_timer <= 0.0:
			finish_reload()


func _draw() -> void:
	if feedback_timer <= 0.0:
		return

	draw_line(
		muzzle.position,
		tracer_end,
		Color(1.0, 0.88, 0.38, 0.9),
		tracer_width,
		false
	)

	draw_circle(
		muzzle.position,
		2.5,
		Color(1.0, 0.62, 0.12, 1.0)
	)

	draw_line(
		muzzle.position - aim_direction.rotated(0.7) * 4.0,
		muzzle.position + aim_direction * 6.0,
		Color(1.0, 0.9, 0.45, 1.0),
		1.0,
		false
	)


func set_aim_direction(direction: Vector2) -> void:
	if direction.length_squared() <= 0.001:
		return

	aim_direction = direction.normalized()
	bullet_ray.target_position = (
		aim_direction * weapon_range
	)
	muzzle.position = (
		aim_direction * 14.0
	)


func try_fire() -> void:
	if is_reloading:
		return

	if fire_timer > 0.0:
		return

	if ammo_in_magazine <= 0:
		print("CLICK! Pistol empty.")
		return

	fire()


func fire() -> void:
	ammo_in_magazine -= 1
	fire_timer = fire_cooldown

	bullet_ray.force_raycast_update()
	tracer_end = aim_direction * weapon_range

	if bullet_ray.is_colliding():
		tracer_end = to_local(
			bullet_ray.get_collision_point()
		)

		var hit: Object = bullet_ray.get_collider()

		if (
			hit != null
			and hit.has_method("take_damage")
		):
			hit.call(
				"take_damage",
				damage,
				aim_direction,
				knockback_strength,
				hit_stun_duration
			)

	feedback_timer = tracer_duration
	queue_redraw()

	NoiseSystem.emit_noise(
		global_position,
		gunshot_noise_radius,
		self
	)

	print(
		"BANG! Ammo: ",
		ammo_in_magazine,
		" / ",
		reserve_ammo
	)


func try_reload() -> void:
	if is_reloading:
		return

	if ammo_in_magazine >= magazine_size:
		return

	if reserve_ammo <= 0:
		return

	is_reloading = true
	reload_timer = reload_time
	print("Reloading...")


func finish_reload() -> void:
	var ammo_needed: int = (
		magazine_size - ammo_in_magazine
	)
	var ammo_to_load: int = mini(
		ammo_needed,
		reserve_ammo
	)

	ammo_in_magazine += ammo_to_load
	reserve_ammo -= ammo_to_load
	is_reloading = false

	print(
		"Reload complete. Ammo: ",
		ammo_in_magazine,
		" / ",
		reserve_ammo
	)


func get_ammo_text() -> String:
	if is_reloading:
		return "RELOADING"

	return "%d / %d" % [
		ammo_in_magazine,
		reserve_ammo
	]


func exclude_survivor_from_bullet_ray() -> void:
	var node: Node = get_parent()

	while node != null:
		if node is CharacterBody2D:
			bullet_ray.add_exception(
				node as CollisionObject2D
			)
			return

		node = node.get_parent()
