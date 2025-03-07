class_name three_division_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/three_division_item.png"
	item_name = "Деление на два."
	description = "Заставляет следующее действие выполнится дважды.\r\n-20% урона.\r\n+50% разброса."
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 1.0

func action(actor: Player) -> int:
	actor.damage_multiplier += -0.2
	actor.spread_multiplier += 0.5
	return use_delay

func compile_into_stack(stack: Array) -> int:
	stack.push_front(self)
	return 2
