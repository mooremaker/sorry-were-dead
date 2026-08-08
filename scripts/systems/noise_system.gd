extends Node


signal noise_emitted(
	position: Vector2,
	radius: float,
	source: Node2D
)


func emit_noise(
	position: Vector2,
	radius: float,
	source: Node2D
) -> void:
	noise_emitted.emit(
		position,
		radius,
		source
	)
