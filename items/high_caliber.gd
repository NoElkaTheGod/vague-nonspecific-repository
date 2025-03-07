class_name high_caliber_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/hugh_caliber_item.png"
	item_name = "Тяжёлый выстрел."
	description = "+100% к отдаче.\r\n+0,25 секунд задержки действия.\r\n-20% скорости снаряда.\r\n+50% урона."
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 0.9

func action(actor: Player) -> int:
	actor.cooldown_offset += 15
	actor.recoil_multiplier += 1.0
	actor.projectile_velocity_multiplier -= 0.2
	actor.damage_multiplier += 0.5
	return use_delay
