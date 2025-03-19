class_name LootManager extends Node

var available_actions: Array[Action]
var actions_total_weight: float
var available_modifiers: Array[Action]
var modifiers_total_weight: float

func _ready() -> void:
	var item_names = DirAccess.get_files_at("res://items")
	for item in item_names:
		if item.ends_with(".uid") or item.ends_with(".remap"): continue
		var new_item: Action = load("res://items/" + item).new()
		add_child(new_item)
		new_item._ready()
		match new_item.item_type:
			new_item.ITEM_TYPE.ACTION:
				actions_total_weight += new_item.weight
				available_actions.append(new_item)
			new_item.ITEM_TYPE.MODIFIER:
				modifiers_total_weight += new_item.weight
				available_modifiers.append(new_item)

func get_random_action(exceptions: Array[Action]) -> Action:
	var available_actions_copy = available_actions.duplicate(true)
	var actions_total_weight_copy = actions_total_weight
	for exception in exceptions:
		available_actions_copy.erase(exception)
		actions_total_weight_copy -= exception.weight
	var number = randf_range(0, actions_total_weight_copy)
	for i in range(available_actions_copy.size()):
		number -= available_actions_copy[i].weight
		if number <= 0.0: return available_actions_copy[i]
	return available_actions_copy[available_actions_copy.size() - 1]

func get_random_modifier(exceptions: Array[Action]) -> Action:
	var available_modifiers_copy = available_modifiers.duplicate(true)
	var modifiers_total_weight_copy = modifiers_total_weight
	for exception in exceptions:
		available_modifiers_copy.erase(exception)
		modifiers_total_weight_copy -= exception.weight
	var number = randf_range(0, modifiers_total_weight_copy)
	for i in range(available_modifiers_copy.size()):
		number -= available_modifiers_copy[i].weight
		if number <= 0.0: return available_modifiers_copy[i]
	return available_modifiers_copy[available_modifiers_copy.size() - 1]
