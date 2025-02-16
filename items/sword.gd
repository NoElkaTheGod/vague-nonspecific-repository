class_name sword_item extends Action


func _ready() -> void:
	texture = "res://sprites/items/sword_item.png"
	item_name = "Меч"
	description = "Это специальный меч для космического корабля. Не спрашивайте. Может парировать снаряды."
	use_delay = 10

func action(actor: Player) -> int:
	actor.melee_hit_animation.flip_h = not actor.melee_hit_animation.flip_h
	actor.melee_hit_animation.play()
	actor.melee_hit_animation.visible = true
	actor.melee_swing_sound_emitter.play()
	var hit_sound := 0
	var bodies := actor.melee_hit_area.get_overlapping_bodies()
	for body in bodies:
		if body == self: continue
		if body is RigidBody2D:
			hit_sound = 1
			body.linear_velocity += (body.position - actor.position).normalized() * 300
			if body is Player:
				body.start_dying(self, 2)
			elif body is Mine:
				body.linear_velocity += (body.position - actor.position).normalized() * 400
		if body is CharacterBody2D:
			hit_sound = 1
			body.velocity = (body.position - actor.position).normalized() * 600
			if body is projectile:
				hit_sound = 2
		if hit_sound == 1: actor.melee_hit_sound_emitter.play()
		if hit_sound == 2: actor.melee_parry_sound_emitter.play()
	return use_delay
