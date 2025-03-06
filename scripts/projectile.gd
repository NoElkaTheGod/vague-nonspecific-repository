class_name Projectile extends ProjectileBase

func init() -> void:
	timer = 300
	damage = 20
	sound.play()
	for exception in get_collision_exceptions():
		remove_collision_exception_with(exception)
