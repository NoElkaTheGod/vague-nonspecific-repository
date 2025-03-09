class_name Missile extends ProjectileBase

var target_velocity := 1100.0

func init() -> void:
	remainder_scene = load("res://scenes/missile_remainder.tscn")
	timer = 300
	damage = 20
	target_velocity = 1100
	sound.play()
	for exception in get_collision_exceptions():
		remove_collision_exception_with(exception)

func custom_process_behaviour(_delta: float) -> void:
	velocity = velocity.lerp(velocity.normalized() * target_velocity, 0.05)

func custom_collision_behaviour(_collision: KinematicCollision2D) -> void:
	var sas = get_node("Area2D") as Area2D
	for body in sas.get_overlapping_bodies():
		if body is RigidBody2D:
			body.linear_velocity += (body.position - position).normalized() * 300
		if body.has_node("HealthComponent"):
			body.get_node("HealthComponent").take_damage(self, damage / 2.0)
