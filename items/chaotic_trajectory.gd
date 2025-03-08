class_name chaotic_trajectory_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/chaotic_trajectory_item.png"
	item_name = "Искривление."
	description = "Случайным образом закручивает снаряд.\r\nx80% перезарядки.\r\nx80% задержки действия."
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 1.0

func action(actor: Player) -> int:
	actor.reload_multiplier *= 0.8
	actor.cooldown_multiplier *= 0.8
	if actor.is_comp_present(chaotic_trajectory_component):
		for item in actor.projectile_components:
			if item is chaotic_trajectory_component:
				item.anomaly *= 2
				break
	else:
		actor.add_comp(chaotic_trajectory_component)
	return use_delay
