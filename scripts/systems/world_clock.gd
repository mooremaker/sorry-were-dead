extends Node


signal minute_changed(
	day: int,
	hour: int,
	minute: int
)

signal hour_changed(
	day: int,
	hour: int
)

signal day_changed(
	day: int
)


@export_category("Time Speed")

# 0.30 means:
# 1 real second = 0.30 game minutes.
#
# 6:00 AM -> midnight takes about 60 real minutes.
# A 6-hour work shift takes about 20 real minutes.
@export var game_minutes_per_real_second: float = 0.30


@export_category("Starting Time")

@export var starting_day: int = 1
@export var starting_hour: int = 6
@export var starting_minute: int = 0


var current_day: int = 1
var current_hour: int = 6
var current_minute: int = 0

var minute_progress: float = 0.0
var is_paused: bool = false


func _ready() -> void:
	current_day = starting_day
	current_hour = starting_hour
	current_minute = starting_minute


func _process(delta: float) -> void:
	if is_paused:
		return

	minute_progress += (
		game_minutes_per_real_second * delta
	)

	while minute_progress >= 1.0:
		minute_progress -= 1.0
		advance_one_minute()


func advance_one_minute() -> void:
	current_minute += 1

	if current_minute >= 60:
		current_minute = 0
		current_hour += 1

		if current_hour >= 24:
			current_hour = 0
			current_day += 1

			day_changed.emit(
				current_day
			)

		hour_changed.emit(
			current_day,
			current_hour
		)

	minute_changed.emit(
		current_day,
		current_hour,
		current_minute
	)


func get_time_text() -> String:
	var display_hour: int = current_hour % 12

	if display_hour == 0:
		display_hour = 12

	var suffix: String = "AM"

	if current_hour >= 12:
		suffix = "PM"

	return "%d:%02d %s" % [
		display_hour,
		current_minute,
		suffix
	]


func get_day_text() -> String:
	return "DAY %d" % current_day


func pause_clock() -> void:
	is_paused = true


func resume_clock() -> void:
	is_paused = false


func set_time(
	day: int,
	hour: int,
	minute: int
) -> void:
	current_day = maxi(
		day,
		1
	)

	current_hour = clampi(
		hour,
		0,
		23
	)

	current_minute = clampi(
		minute,
		0,
		59
	)

	minute_progress = 0.0


func sleep_until_morning() -> void:
	current_day += 1
	current_hour = 6
	current_minute = 0
	minute_progress = 0.0

	day_changed.emit(
		current_day
	)

	hour_changed.emit(
		current_day,
		current_hour
	)

	minute_changed.emit(
		current_day,
		current_hour,
		current_minute
	)
