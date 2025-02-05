class_name MainCamera extends Camera2D

@onready var game_manager: GameManager = get_parent()
@onready var ui: UI = $UI
var camera_return_to_center := true

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

func get_random_spot_offscreen(direction: int) -> Vector2:
	var arena_size := Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y)
	return Vector2(randf_range(50, arena_size.x - 50), (arena_size.y * direction) + (50 * direction) - (50 * (-direction + 1)))

func _process(_delta: float) -> void:
	recalculate_camera_bounds()
	ui.global_position = position - (get_viewport_rect().size / zoom / 2.0)

func recalculate_camera_bounds() -> void:
	var players_rect := Rect2(100, 100, 1820, 1180)
	var target_position : Vector2
	var target_zoom : Vector2
	if not camera_return_to_center:
		var max_position := Vector2(960, 640)
		var min_position := Vector2(960, 640)
		for player in game_manager.players:
			if not player.is_player_active: continue
			if player.position.x > max_position.x: max_position.x = player.position.x
			if player.position.y > max_position.y: max_position.y = player.position.y
			if player.position.x < min_position.x: min_position.x = player.position.x
			if player.position.y < min_position.y: min_position.y = player.position.y
		max_position += Vector2(200, 200)
		min_position -= Vector2(200, 200)
		players_rect = Rect2(min_position, max_position - min_position)
		target_position = players_rect.get_center()
		target_zoom = get_viewport_rect().size / players_rect.size
		target_zoom.x = min(target_zoom.x, target_zoom.y)
		target_zoom.y = min(target_zoom.x, target_zoom.y)
		target_zoom = target_zoom.clamp(Vector2.ZERO, Vector2.ONE)
	else:
		target_position = Vector2(960, 640)
		target_zoom = get_viewport_rect().size / Vector2(1920, 1280) * Vector2(0.9, 0.9)
		target_zoom.x = min(target_zoom.x, target_zoom.y)
		target_zoom.y = min(target_zoom.x, target_zoom.y)
	zoom = zoom.lerp(target_zoom, 0.1)
	zoom = zoom.move_toward(target_zoom, 0.001)
	ui.scale = Vector2.ONE / zoom
	position = position.lerp(target_position, 0.1)
	position = position.move_toward(target_position, 5)
