class_name mine_item extends Action


func _ready() -> void:
	texture = "res://sprites/items/mine_item.png"
	item_name = "Мина."
	description = "Взорвётся, если кто-нибудь приблизится к ней.\r\n30 урона.\r\n2 секунды задержки действия."
	use_delay = 120
	weight = 1.0
	associated_scene = load("res://scenes/mine.tscn")

func action(actor: Player) -> int:
	var mine: Mine = associated_scene.instantiate()
	actor.game_manager.projectile_container.add_child(mine)
	mine.init()
	@warning_ignore("narrowing_conversion")
	mine.damage *= actor.damage_multiplier
	mine.visible = true
	mine.process_mode = Node.PROCESS_MODE_PAUSABLE
	mine.position = actor.position + (Vector2(cos(actor.rotation), sin(actor.rotation)) * 50).rotated(actor.angle_offset)
	mine.linear_velocity = (Vector2(cos(actor.rotation), sin(actor.rotation)) * 250).rotated(actor.angle_offset) * actor.projectile_velocity_multiplier + actor.linear_velocity
	actor.linear_velocity += Vector2(cos(actor.rotation), sin(actor.rotation)).rotated(actor.angle_offset + PI) * 80.0 * actor.recoil_multiplier
	for component in components:
		mine.components.append(component)
		mine.add_child(component)
	components.clear()
	component_classes.clear()
	return use_delay
