class_name missile_item extends Action


func _ready() -> void:
	texture = "res://sprites/items/missile_item.png"
	item_name = "Ракета"
	description = "Запускает ракету. Не самонаводится, но взрывается. 20 урона при попадании, вдвое меньше по области."
	use_delay = 20
	weight = 0.5
	associated_scene = load("res://scenes/missile.tscn")

func action(actor: Player) -> int:
	actor.reload_offset += 10
	var spread := Vector2(randf_range(-5, 5), randf_range(-5, 5)) * actor.spread_multiplier
	var proj: Missile = associated_scene.instantiate()
	actor.game_manager.projectile_container.add_child(proj)
	proj.init()
	proj.target_velocity *= actor.projectile_velocity_multiplier
	proj.add_collision_exception_with(actor)
	proj.damage *= actor.damage_multiplier
	proj.visible = true
	proj.process_mode = Node.PROCESS_MODE_PAUSABLE
	proj.position = actor.position + (Vector2(cos(actor.rotation), sin(actor.rotation)) * 20).rotated(actor.angle_offset)
	proj.velocity = (Vector2(cos(actor.rotation), sin(actor.rotation)) * 150.0).rotated(actor.angle_offset) * actor.projectile_velocity_multiplier + spread
	actor.linear_velocity += Vector2(cos(actor.rotation), sin(actor.rotation)).rotated(actor.angle_offset + PI) * 50.0 * actor.recoil_multiplier
	for component in components:
		proj.components.append(component)
		proj.add_child(component)
	components.clear()
	component_classes.clear()
	return use_delay
