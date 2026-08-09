extends CanvasLayer


@onready var overlay: Control = $Overlay
@onready var load_button: Button = $Overlay/CenterPanel/Layout/LoadButton
@onready var quit_button: Button = $Overlay/CenterPanel/Layout/QuitButton
@onready var save_status: Label = $Overlay/CenterPanel/Layout/SaveStatus


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.visible = false

	GameState.all_active_players_down.connect(
		_on_all_active_players_down
	)

	load_button.pressed.connect(
		_on_load_pressed
	)

	quit_button.pressed.connect(
		_on_quit_pressed
	)


func _on_all_active_players_down() -> void:
	overlay.visible = true

	load_button.disabled = not SaveSystem.has_last_save()

	if SaveSystem.has_last_save():
		save_status.text = "RETURN TO YOUR LAST CHECKPOINT"
	else:
		save_status.text = "NO CHECKPOINT AVAILABLE"

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	WorldClock.pause_clock()
	get_tree().paused = true


func _on_load_pressed() -> void:
	if not SaveSystem.load_last_save():
		save_status.text = "COULD NOT LOAD CHECKPOINT"


func _on_quit_pressed() -> void:
	get_tree().paused = false
	WorldClock.resume_clock()
	get_tree().quit()
