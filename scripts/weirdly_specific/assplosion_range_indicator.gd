extends Sprite2D

func _process(delta: float) -> void:
	rotate(delta * 10)
	scale *= 0.99
	modulate *= Color(1, 1, 1, 0.95)
