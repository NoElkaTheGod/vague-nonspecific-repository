class_name push_item extends Action

func _ready() -> void:
	texture = "res://sprites/items/push_item.png"
	item_name = "Гравитационный всплеск."
	description = "Отталкивает предметы.\r\nМножитель урона влияет на силу толчка.\r\nМножитель скорости снаряда влияет на размер области.\r\n0,33 секунды задержки действия."
	use_delay = 20
	weight = 0.8
	associated_scene = load("res://scenes/push.tscn")

func action(actor: Player) -> int:
	var proj: Push = associated_scene.instantiate()
	actor.game_manager.projectile_container.add_child(proj)
	proj.radius = 50 * actor.projectile_velocity_multiplier
	proj.position = actor.position + (Vector2(cos(actor.rotation), sin(actor.rotation)) * 30).rotated(actor.angle_offset)
	proj.rotation = actor.rotation
	proj.power *= actor.damage_multiplier
	proj.origin_position = actor.position
	actor.linear_velocity += Vector2(cos(actor.rotation), sin(actor.rotation)).rotated(actor.angle_offset + PI) * 50.0 * actor.recoil_multiplier
	for component in components:
		proj.components.append(component)
		proj.add_child(component)
	components.clear()
	component_classes.clear()
	proj.activate()
	return use_delay
