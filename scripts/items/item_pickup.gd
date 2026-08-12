extends Area2D


@export_category("Item")
@export var item_id: String = "scrap"
@export var display_name: String = "Scrap"
@export var amount: int = 1

@export_category("Appearance")
@export var pickup_color: Color = Color(
	0.9,
	0.75,
	0.2,
	1.0
)


var nearby_survivor: Node2D = null


@onready var pickup_label: Label = (
	$PickupLabel
)

@onready var body_visual: ColorRect = (
	$Visuals/BodyVisual
)


func _ready() -> void:
	# Keep pickups visually in front of normal world actors.
	z_index = 20

	body_visual.color = pickup_color

	body_entered.connect(
		_on_body_entered
	)

	body_exited.connect(
		_on_body_exited
	)

	pickup_label.visible = false


func _process(_delta: float) -> void:
	if nearby_survivor == null:
		return

	if not Input.is_action_just_pressed(
		"interact"
	):
		return

	try_pickup()


func setup_item(
	new_item_id: String,
	new_display_name: String,
	new_amount: int,
	new_color: Color
) -> void:
	item_id = new_item_id
	display_name = new_display_name
	amount = new_amount
	pickup_color = new_color

	if is_node_ready():
		body_visual.color = pickup_color


func _on_body_entered(
	body: Node2D
) -> void:
	if not body.is_in_group(
		"survivors"
	):
		return

	nearby_survivor = body

	pickup_label.text = (
		"E - PICK UP %s"
		% display_name.to_upper()
	)

	pickup_label.visible = true


func _on_body_exited(
	body: Node2D
) -> void:
	if body != nearby_survivor:
		return

	nearby_survivor = null
	pickup_label.visible = false


func try_pickup() -> void:
	if nearby_survivor == null:
		return

	var inventory: Node = (
		nearby_survivor.get_node_or_null(
			"Inventory"
		)
	)

	if inventory == null:
		return

	if not inventory.has_method(
		"add_item"
	):
		return

	var picked_up: bool = bool(
		inventory.call(
			"add_item",
			item_id,
			amount
		)
	)

	if not picked_up:
		return

	queue_free()
