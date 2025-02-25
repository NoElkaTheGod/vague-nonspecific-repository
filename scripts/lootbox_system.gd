class_name LootManager extends Node

var AvailableActions: Array[Action]
var ActionsTotalWeight: float
var AvailableModifiers: Array[Action]
var ModifiersTotalWeight: float

func _ready() -> void:
	var item_names = DirAccess.get_files_at("res://items")
	for item in item_names:
		var new_item: Action = load("res://items/" + item).new()
		add_child(new_item)
		new_item._ready()
		match new_item.item_type:
			new_item.ITEM_TYPE.ACTION:
				ActionsTotalWeight += new_item.weight
				AvailableActions.append(new_item)
			new_item.ITEM_TYPE.MODIFIER:
				ModifiersTotalWeight += new_item.weight
				AvailableModifiers.append(new_item)

func get_random_action() -> Action:
	var number = randf_range(0, ActionsTotalWeight)
	for i in range(AvailableActions.size()):
		number -= AvailableActions[i].weight
		if number <= 0.0: return AvailableActions[i]
	return AvailableActions[AvailableActions.size() - 1]

func get_random_modifier() -> Action:
	var number = randf_range(0, ModifiersTotalWeight)
	for i in range(AvailableModifiers.size()):
		number -= AvailableModifiers[i].weight
		if number <= 0.0: return AvailableModifiers[i]
	return AvailableModifiers[AvailableModifiers.size() - 1]
