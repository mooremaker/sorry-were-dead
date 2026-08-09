extends Control


@export var crosshair_size: float = 18.0
@export var gap: float = 3.0
@export var line_length: float = 5.0
@export var line_width: float = 1.0

@export var crosshair_color: Color = Color.WHITE
@export var outline_color: Color = Color.BLACK


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("crosshair_ui")

	size = Vector2(
		crosshair_size,
		crosshair_size
	)

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	GameState.all_active_players_down.connect(
		_on_all_active_players_down
	)

	queue_redraw()


func _process(_delta: float) -> void:
	global_position = (
		get_viewport().get_mouse_position()
		- size * 0.5
	)


func _draw() -> void:
	var center: Vector2 = size * 0.5

	draw_crosshair_lines(
		center,
		outline_color,
		3.0
	)

	draw_crosshair_lines(
		center,
		crosshair_color,
		line_width
	)


func draw_crosshair_lines(
	center: Vector2,
	color: Color,
	width: float
) -> void:
	draw_line(
		Vector2(
			center.x,
			center.y - gap - line_length
		),
		Vector2(
			center.x,
			center.y - gap
		),
		color,
		width,
		false
	)

	draw_line(
		Vector2(
			center.x,
			center.y + gap
		),
		Vector2(
			center.x,
			center.y + gap + line_length
		),
		color,
		width,
		false
	)

	draw_line(
		Vector2(
			center.x - gap - line_length,
			center.y
		),
		Vector2(
			center.x - gap,
			center.y
		),
		color,
		width,
		false
	)

	draw_line(
		Vector2(
			center.x + gap,
			center.y
		),
		Vector2(
			center.x + gap + line_length,
			center.y
		),
		color,
		width,
		false
	)


func _on_all_active_players_down() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
