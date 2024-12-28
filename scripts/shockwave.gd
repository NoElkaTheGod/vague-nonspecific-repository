extends Sprite2D

var timer := 0

func do_thing() -> void:
	global_position = get_parent().get_parent().global_position
	timer = 20

func _process(_delta: float) -> void:
	if timer == 0: return
	scale = Vector2((timer / 20.0) - 1, (timer / 20.0) - 1)
	modulate = Color(Color.WHITE, 20.0 / timer)
	timer -= 1
	if timer == 0: modulate = Color(Color.WHITE, 0)
