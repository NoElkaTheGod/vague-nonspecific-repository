class_name chaotic_trajectory_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/chaotic_trajectory_item.png"
	item_name = "Хаотичная траектория"
	description = "Случайным образом отклоняет снаряд. Сокращает перезарядку."
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 1.0

func action(actor: Player) -> int:
	actor.reload_offset += -10
	actor.cooldown_multiplier *= 0.8
	var modifiable := actor.get_next_action()
	if modifiable == null: return use_delay
	if modifiable.has_component(chaotic_trajectory_component):
		for item in modifiable.components:
			if item is chaotic_trajectory_component:
				item.anomaly *= 2
				break
	else:
		modifiable.add_component(chaotic_trajectory_component)
	return use_delay
