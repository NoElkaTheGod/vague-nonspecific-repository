class_name chaotic_trajectory_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/chaotic_trajectory_item.png"
	item_name = "Хаотичная траектория"
	description = "Случайным образом отклоняет снаряд. Сокращает перезарядку."
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 1.0

func action(actor: Player) -> int:
	var modifiable := actor.get_next_action()
	modifiable.add_component(chaotic_trajectory_component)
	actor.reload_offset += -10
	actor.cooldown_multiplier *= 0.8
	return use_delay
