class_name high_caliber_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/hugh_caliber_item.png"
	item_name = "Крупный калибр"
	description = "Снаряд летит медленее, но наносит больше урона. Существенно увеличивает отдачу."
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 0.9

func action(actor: Player) -> int:
	actor.cooldown_multiplier *= 1.2
	actor.recoil_multiplier *= 2.0
	actor.projectile_velocity_multiplier *= 0.4
	actor.damage_multiplier *= 1.6
	return use_delay
