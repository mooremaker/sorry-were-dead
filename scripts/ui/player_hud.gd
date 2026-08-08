extends CanvasLayer


var player: CharacterBody2D = null
var pistol: Node = null

var displayed_noise: float = 0.0


@onready var status_panel: PanelContainer = $StatusPanel

@onready var health_label: Label = (
	$StatusPanel/Stats/HealthLabel
)

@onready var health_bar: ProgressBar = (
	$StatusPanel/Stats/HealthBar
)

@onready var stance_label: Label = (
	$StatusPanel/Stats/StanceLabel
)

@onready var noise_bar: ProgressBar = (
	$StatusPanel/Stats/NoiseBar
)

@onready var weapon_label: Label = (
	$StatusPanel/Stats/WeaponLabel
)

@onready var ammo_label: Label = (
	$StatusPanel/Stats/AmmoLabel
)

@onready var status_label: Label = (
	$StatusPanel/Stats/StatusLabel
)

@onready var day_label: Label = (
	$ClockPanel/ClockStats/DayLabel
)

@onready var time_label: Label = (
	$ClockPanel/ClockStats/TimeLabel
)


func _ready() -> void:
	call_deferred("find_player")


func _process(delta: float) -> void:
	update_clock()

	if player == null:
		find_player()
		return

	update_health()
	update_stance()
	update_noise(delta)
	update_weapon()
	update_status()


func find_player() -> void:
	var survivor: Node = get_tree().get_first_node_in_group(
		"survivors"
	)

	if survivor == null:
		return

	if survivor is CharacterBody2D:
		player = survivor as CharacterBody2D

	if player != null:
		pistol = player.get_node_or_null(
			"WeaponSocket/Pistol"
		)


func update_health() -> void:
	var current: float = float(
		player.get("current_health")
	)

	var maximum: float = float(
		player.get("max_health")
	)

	health_bar.max_value = maximum
	health_bar.value = current

	health_label.text = (
		"HP %d / %d"
		% [int(current), int(maximum)]
	)


func update_stance() -> void:
	var is_down: bool = bool(
		player.get("is_down")
	)

	var is_crouching: bool = bool(
		player.get("is_crouching")
	)

	var is_sprinting: bool = bool(
		player.get("is_sprinting")
	)

	if is_down:
		stance_label.text = "STANCE: DOWN"
		return

	if not player.is_on_floor():
		stance_label.text = "STANCE: AIR"
		return

	if is_crouching:
		stance_label.text = "STANCE: SNEAK"
		return

	if is_sprinting:
		stance_label.text = "STANCE: SPRINT"
		return

	if absf(player.velocity.x) > 5.0:
		stance_label.text = "STANCE: WALK"
		return

	stance_label.text = "STANCE: IDLE"


func update_noise(delta: float) -> void:
	var target_noise: float = 0.0

	var is_down: bool = bool(
		player.get("is_down")
	)

	var is_crouching: bool = bool(
		player.get("is_crouching")
	)

	var is_sprinting: bool = bool(
		player.get("is_sprinting")
	)

	var sprint_noise: float = float(
		player.get("sprint_noise_radius")
	)

	noise_bar.max_value = maxf(
		sprint_noise,
		1.0
	)

	if not is_down and absf(player.velocity.x) > 5.0:
		if is_crouching:
			target_noise = float(
				player.get("crouch_noise_radius")
			)

		elif is_sprinting:
			target_noise = sprint_noise

		else:
			target_noise = float(
				player.get("walk_noise_radius")
			)

	displayed_noise = move_toward(
		displayed_noise,
		target_noise,
		350.0 * delta
	)

	noise_bar.value = displayed_noise

	update_noise_color()


func update_noise_color() -> void:
	var fill_style: StyleBoxFlat = StyleBoxFlat.new()

	var maximum_noise: float = maxf(
		float(noise_bar.max_value),
		1.0
	)

	var noise_ratio: float = (
		displayed_noise / maximum_noise
	)

	if noise_ratio < 0.4:
		fill_style.bg_color = Color(
			0.2,
			0.85,
			0.25,
			1.0
		)

	elif noise_ratio < 0.8:
		fill_style.bg_color = Color(
			0.95,
			0.8,
			0.15,
			1.0
		)

	else:
		fill_style.bg_color = Color(
			0.9,
			0.15,
			0.1,
			1.0
		)

	noise_bar.add_theme_stylebox_override(
		"fill",
		fill_style
	)


func update_weapon() -> void:
	if pistol == null:
		weapon_label.visible = false
		ammo_label.visible = false
		return

	weapon_label.visible = true
	ammo_label.visible = true

	weapon_label.text = "PISTOL"

	if pistol.has_method("get_ammo_text"):
		ammo_label.text = pistol.get_ammo_text()


func update_status() -> void:
	var is_down: bool = bool(
		player.get("is_down")
	)

	if status_label.visible == is_down:
		return

	status_label.visible = is_down

	if is_down:
		status_label.text = "DOWNED"
	else:
		status_label.text = ""

	status_panel.call_deferred(
		"reset_size"
	)


func update_clock() -> void:
	day_label.text = WorldClock.get_day_text()
	time_label.text = WorldClock.get_time_text()
