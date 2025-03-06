class_name chaotic_trajectory_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/chaotic_trajectory_item.png"
	item_name = "Искривление."
	description = "Случайным образом закручивает снаряд. -0,25 секунд перезарядки. -0,25 секунд задержки действия. "
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 1.0

func action(actor: Player) -> int:
	actor.reload_offset += -15
	actor.cooldown_offset += -15
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
