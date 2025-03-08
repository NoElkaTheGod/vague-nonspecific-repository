class_name laser_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/laser_item.png"
	item_name = "Снаряд."
	description = "Стреляет не очень реалистичным лазером.\r\n15 урона при попадании.\r\n0,25 секунды задержки действия."
	use_delay = 15
	weight = 0.6
	associated_scene = load("res://scenes/laser.tscn")

func action(actor: Player) -> int:
	var spread := randf_range(-0.05, 0.05) * actor.spread_multiplier
	var proj: Laser = associated_scene.instantiate()
	actor.game_manager.projectile_container.add_child(proj)
	proj.damage *= actor.damage_multiplier
	proj.position = actor.position + (Vector2(cos(actor.rotation), sin(actor.rotation)) * 20).rotated(actor.angle_offset + spread)
	proj.rotation = actor.rotation + actor.angle_offset + spread
	actor.linear_velocity += Vector2(cos(actor.rotation), sin(actor.rotation)).rotated(actor.angle_offset + PI) * 50.0 * actor.recoil_multiplier
	for component in components:
		proj.components.append(component)
		proj.add_child(component)
	proj.activate()
	components.clear()
	component_classes.clear()
	return use_delay
