extends CanvasLayer


var player: Node = null


@onready var health_label: Label = (
	$StatusPanel/Stats/HealthLabel
)

@onready var health_bar: ProgressBar = (
	$StatusPanel/Stats/HealthBar
)

@onready var stance_label: Label = (
	$StatusPanel/Stats/StanceLabel
)

@onready var noise_label: Label = (
	$StatusPanel/Stats/NoiseLabel
)

@onready var status_label: Label = (
	$StatusPanel/Stats/StatusLabel
)


func _ready() -> void:
	call_deferred("find_player")


func _process(_delta: float) -> void:
	if player == null:
		return

	update_health()
	update_stance()
	update_noise()
	update_status()


func find_player() -> void:
	player = get_tree().get_first_node_in_group(
		"survivors"
	)


func update_health() -> void:
	var current: float = player.current_health
	var maximum: float = player.max_health

	health_bar.max_value = maximum
	health_bar.value = current

	health_label.text = (
		"HP %d / %d"
		% [int(current), int(maximum)]
	)


func update_stance() -> void:
	if player.is_down:
		stance_label.text = "STANCE: DOWN"
		return

	if not player.is_on_floor():
		stance_label.text = "STANCE: AIR"
		return

	if player.is_crouching:
		stance_label.text = "STANCE: SNEAK"
		return

	if player.is_sprinting:
		stance_label.text = "STANCE: SPRINT"
		return

	if absf(player.velocity.x) > 5.0:
		stance_label.text = "STANCE: WALK"
		return

	stance_label.text = "STANCE: IDLE"


func update_noise() -> void:
	if player.is_down:
		noise_label.text = "NOISE: 0"
		return

	var radius: float = 0.0

	if absf(player.velocity.x) > 5.0:
		if player.is_crouching:
			radius = player.crouch_noise_radius

		elif player.is_sprinting:
			radius = player.sprint_noise_radius

		else:
			radius = player.walk_noise_radius

	noise_label.text = "NOISE: %d" % int(radius)


func update_status() -> void:
	if player.is_down:
		status_label.text = "DOWNED"
	else:
		status_label.text = ""
