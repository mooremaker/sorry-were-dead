extends Node2D


@export_category("Damage")
@export var damage: float = 25.0
@export var weapon_range: float = 500.0


@export_category("Ammo")
@export var magazine_size: int = 8
@export var reserve_ammo: int = 24
@export var reload_time: float = 1.2


@export_category("Fire")
@export var fire_cooldown: float = 0.25
@export var gunshot_noise_radius: float = 650.0


var ammo_in_magazine: int = 8

var fire_timer: float = 0.0
var reload_timer: float = 0.0

var is_reloading: bool = false
var facing_direction: float = 1.0


@onready var bullet_ray: RayCast2D = $BulletRay
@onready var muzzle: Marker2D = $Muzzle


func _ready() -> void:
	ammo_in_magazine = magazine_size


func _process(delta: float) -> void:
	fire_timer = maxf(
		fire_timer - delta,
		0.0
	)

	if is_reloading:
		reload_timer -= delta

		if reload_timer <= 0.0:
			finish_reload()


func set_facing_direction(direction: float) -> void:
	if direction == 0.0:
		return

	facing_direction = direction

	bullet_ray.target_position = Vector2(
		weapon_range * facing_direction,
		0.0
	)

	muzzle.position.x = 14.0 * facing_direction


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

	if bullet_ray.is_colliding():
		var hit: Object = bullet_ray.get_collider()

		if hit != null and hit.has_method("take_damage"):
			hit.take_damage(damage)

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
