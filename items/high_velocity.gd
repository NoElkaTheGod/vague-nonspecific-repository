class_name high_velocity_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/high_velocity_item.png"
	item_name = "Быстрый выстрел."
	description = "+100% отдачи. +40% скорости снаряда. +20% урона. "
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 0.9

func action(actor: Player) -> int:
	actor.recoil_multiplier += 1.0
	actor.projectile_velocity_multiplier += 0.45
	actor.damage_multiplier += 0.2
	return use_delay
