extends Node2D


func _ready() -> void:
	if SaveSystem.is_loading_save:
		return

	call_deferred("create_entry_checkpoint")


func create_entry_checkpoint() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	SaveSystem.save_checkpoint()
