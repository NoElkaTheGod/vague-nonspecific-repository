class_name high_velocity_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/high_velocity_item.png"
	item_name = "Высокая скорость"
	description = "Снаряд летит быстрее и наносит больше урона. Так же увеличивает отдачу."
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 0.9

func action(actor: Player) -> int:
	actor.cooldown_multiplier *= 1.2
	actor.recoil_multiplier *= 1.5
	actor.projectile_velocity_multiplier *= 2.0
	actor.damage_multiplier *= 1.6
	return use_delay
