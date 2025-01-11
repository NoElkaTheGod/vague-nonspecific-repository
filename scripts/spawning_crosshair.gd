extends Node2D

func init(player: Player) -> void:
	global_position = player.global_position
	match player.character_color:
		0:
			modulate = Color(0.4, 0.4, 1.0)
		1:
			modulate = Color(1, 0.2, 0.2)
		2:
			modulate = Color(0.4, 1, 0.4)
		3:
			modulate = Color(1.0, 1.0, 0.1)
	scale = Vector2.ONE * 2.0

func _process(delta: float) -> void:
	scale = scale.lerp(Vector2.ONE, 0.04)
	rotate(delta * PI * ((scale.x - 1) / 2.0) * 4)
	modulate = modulate * Color(1, 1, 1, 0.97)
	if scale.x <= 1.1:
		queue_free()
