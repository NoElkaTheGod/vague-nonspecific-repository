class_name missile_item extends Action


func _ready() -> void:
	texture = "res://sprites/items/missile_item.png"
	item_name = "Ракета"
	description = "Запускает ракету. Не самонаводится, но взрывается. 20 урона при попадании, вдвое меньше по области."
	use_delay = 30
	weight = 0.5

func action(actor: Player) -> int:
	if actor.idle_projectile_manager == null: return use_delay
	actor.shot_sound_emitter.play()
	var spread := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * actor.spread_multiplier
	var proj: Missile = actor.idle_projectile_manager.get_idle_missile()
	proj.init()
	proj.visible = true
	proj.process_mode = Node.PROCESS_MODE_PAUSABLE
	proj.position = actor.position + (Vector2(cos(actor.rotation), sin(actor.rotation)) * 50).rotated(actor.angle_offset)
	var actor_velocity = actor.linear_velocity.project(Vector2.RIGHT.rotated(actor.rotation))
	proj.velocity = (Vector2(cos(actor.rotation), sin(actor.rotation)) * randf_range(150, 200)).rotated(actor.angle_offset) + actor_velocity + spread
	for component in components:
		proj.components.append(component)
		proj.add_child(component)
	components.clear()
	component_classes.clear()
	return use_delay
