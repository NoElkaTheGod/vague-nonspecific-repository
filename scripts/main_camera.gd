class_name MainCamera extends Camera2D

func _ready() -> void:
	get_viewport().connect("size_changed", viewport_size_changed)
	viewport_size_changed()

func get_arena_corner(a: int) -> Vector2:
	var result: Array[Vector2]
	result.resize(4)
	var arena_size := Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y)
	result[0] = Vector2(arena_size.x - 40, 40)
	result[1] = Vector2(40, arena_size.y - 40)
	result[2] = Vector2(arena_size.x - 40, arena_size.y - 40)
	result[3] = Vector2(40, 40)
	return result[a]

func get_arena_corner_direction(a: int) -> float:
	var result: Array[float]
	result.resize(4)
	result[0] = deg_to_rad(135.0)
	result[1] = deg_to_rad(315.0)
	result[2] = deg_to_rad(225.0)
	result[3] = deg_to_rad(45.0)
	return result[a]

func get_random_spot() -> Vector2:
	var arena_size := Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y)
	return Vector2(randf_range(50, arena_size.x - 50), randf_range(50, arena_size.y - 50))

func viewport_size_changed():
	var new_size := Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y)
	$UpBound.position = Vector2(new_size.x / 2, 0)
	$LeftBound.position = Vector2(0, new_size.y / 2)
	$RightBound.position = Vector2(new_size.x, new_size.y / 2)
	$DownBound.position = Vector2(new_size.x / 2, new_size.y)
