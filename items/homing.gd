class_name homing_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/homing_item.png"
	item_name = "Самонаведение."
	description = "Заставляет снаряды самонаводится на противника.\r\n+0.125 секунд к задержке действия.\r\n+0.5 секунд к перезарядке."
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 0.3

func action(actor: Player) -> int:
	actor.reload_offset += 30
	actor.cooldown_offset += 10
	if actor.is_comp_present(homing_component):
		for item in actor.projectile_components:
			if item is homing_component:
				item.scale *= 1.5
				item.strength *= 2
				break
	else:
		actor.add_comp(homing_component)
	return use_delay
