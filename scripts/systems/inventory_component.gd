extends Node


signal inventory_changed


@export_category("Inventory")
@export var max_slots: int = 8


var items: Dictionary = {}


func add_item(
	item_id: String,
	amount: int = 1
) -> bool:
	if amount <= 0:
		return false

	var already_has_item: bool = items.has(
		item_id
	)

	if (
		not already_has_item
		and get_used_slots() >= max_slots
	):
		print("Inventory full.")
		return false

	var current_amount: int = get_amount(
		item_id
	)

	items[item_id] = (
		current_amount + amount
	)

	inventory_changed.emit()

	print(
		"Picked up ",
		amount,
		" x ",
		item_id
	)

	return true


func remove_item(
	item_id: String,
	amount: int = 1
) -> bool:
	if amount <= 0:
		return false

	if not items.has(item_id):
		return false

	var current_amount: int = get_amount(
		item_id
	)

	if current_amount < amount:
		return false

	var remaining_amount: int = (
		current_amount - amount
	)

	if remaining_amount <= 0:
		items.erase(item_id)
	else:
		items[item_id] = remaining_amount

	inventory_changed.emit()

	return true


func get_amount(
	item_id: String
) -> int:
	if not items.has(item_id):
		return 0

	return int(
		items[item_id]
	)


func has_item(
	item_id: String,
	amount: int = 1
) -> bool:
	return (
		get_amount(item_id) >= amount
	)


func get_used_slots() -> int:
	return items.size()


func get_max_slots() -> int:
	return max_slots


func get_display_name(
	item_id: String
) -> String:
	match item_id:
		"scrap":
			return "SCRAP"

		"9mm_ammo":
			return "9MM AMMO"

		"canned_food":
			return "CANNED FOOD"

		"bottled_water":
			return "BOTTLED WATER"

		"medicine":
			return "MEDICINE"

		_:
			return item_id.replace(
				"_",
				" "
			).to_upper()


func get_inventory_text() -> String:
	if items.is_empty():
		return "EMPTY"

	var lines: PackedStringArray = []

	for item_id_variant: Variant in items.keys():
		var item_id: String = str(
			item_id_variant
		)

		var amount: int = get_amount(
			item_id
		)

		var display_name: String = (
			get_display_name(
				item_id
			)
		)

		lines.append(
			"%s  x%d"
			% [
				display_name,
				amount
			]
		)

	return "\n".join(lines)
