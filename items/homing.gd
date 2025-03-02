class_name homing_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/homing_item.png"
	item_name = "Самонаведение"
	description = "Заставляет снаряд самонаводится на противников. Замедляет перезарядку."
	item_type = ITEM_TYPE.MODIFIER
	trigger_next_immediately = true
	weight = 0.3

func action(actor: Player) -> int:
	actor.reload_offset += 10
	actor.cooldown_multiplier *= 2.0
	var modifiable := actor.get_next_action()
	if modifiable == null: return use_delay
	if modifiable.has_component(homing_component):
		for item in modifiable.components:
			if item is homing_component:
				item.scale *= 1.5
				item.strength *= 2
				break
	else:
		var comp := modifiable.add_component(homing_component) as homing_component
		comp.actor = actor
	return use_delay
