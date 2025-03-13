class_name FishController extends Node

var segment_lengths: Array[float] = [9, 14, 15, 15, 12, 9, 7, 5, 4, 3, 2]
var segment_positions: Array[Vector2]
var segment_angles: Array[float]
var parts: Dictionary[String, Node2D]
@export var proxy_body: Node

const SEGMENT_PADDING = 2

@onready var visual_polygon: Polygon2D = $BodyPolygon
@onready var parts_container: Node = $PartsContainer


func _ready() -> void:
	var accumulated_position: float = 0
	for i in range(segment_lengths.size()):
		segment_angles.append(0)
		segment_positions.append(Vector2(accumulated_position, 0))
		accumulated_position += segment_lengths[i]
	for part in parts_container.get_children():
		parts.set(part.name, part)

const MAX_SEGMENT_ANGLE = deg_to_rad(30)

func _physics_process(_delta: float) -> void:
	for i in range(1, segment_positions.size()):
		var prev_seg_pos: Vector2 = segment_positions[i - 1]
		var cur_seg_pos: Vector2 = segment_positions[i]
		var prev_seg_size: float = segment_lengths[i - 1]
		segment_positions[i] = ((cur_seg_pos - prev_seg_pos).normalized() * prev_seg_size) + prev_seg_pos
		if i < segment_positions.size() - 1:
			var next_seg_pos: Vector2 = segment_positions[i + 1]
			segment_angles[i] = prev_seg_pos.angle_to_point(next_seg_pos)
		segment_positions[i] = segment_positions[i].lerp(Vector2(cos(segment_angles[i - 1]), sin(segment_angles[i - 1])) * prev_seg_size + prev_seg_pos, 0.8)

const HEAD_VERTICIES = 7
const TAIL_VERTICIES = 5
var body_polygon: Array[Vector2]

func _process(_delta: float) -> void:
	body_polygon.clear()
	var polygon_left: Array[Vector2]
	var polygon_right: Array[Vector2]
	var polygon_head: Array[Vector2]
	var polygon_tail: Array[Vector2]
	for i in range(HEAD_VERTICIES + 1):
		var angle: float = -(PI / 2) + ((PI / HEAD_VERTICIES) * i)
		polygon_head.append(get_segment_position(0, angle, segment_lengths[0]))
	for i in range(TAIL_VERTICIES + 1):
		var angle: float = -(PI / 2) + (PI / TAIL_VERTICIES * i)
		polygon_tail.append(get_segment_position(segment_positions.size() - 1, angle, segment_lengths[-1]))
	for i in range(1, segment_positions.size() - 1):
		polygon_right.append(get_segment_position(i, - PI / 2, segment_lengths[i]))
		polygon_left.append(get_segment_position(i, PI / 2, segment_lengths[i]))
	polygon_left.reverse()
	body_polygon.append_array(polygon_head)
	body_polygon.append_array(polygon_right)
	body_polygon.append_array(polygon_tail)
	body_polygon.append_array(polygon_left)
	visual_polygon.polygon = interpolate_polygon(body_polygon, 4)
	parts.get("EyeLeft").position = get_segment_position(0, PI / 2, 8)
	parts.get("EyeRight").position = get_segment_position(0, -PI / 2, 8)
	parts.get("FinLeft").position = get_segment_position(2, PI / 2, 20)
	parts.get("FinRight").position = get_segment_position(2, -PI / 2, 20)
	parts.get("FinTail").position = get_segment_position(segment_positions.size() - 1, 0, 5)
	parts.get("FinLeft").rotation = get_segment_rotation(2)
	parts.get("FinRight").rotation = get_segment_rotation(2)
	parts.get("FinTail").rotation = get_segment_rotation(segment_positions.size() - 1)

func get_body_polygon() -> PackedVector2Array:
	return body_polygon

func set_visibility(visible: bool) -> void:
	visual_polygon.visible = visible

func set_position(position: Vector2) -> void:
	segment_positions[0] = position

func set_head_rotation(angle: float) -> void:
	segment_angles[0] = angle + PI

func set_complete_rotation(angle: float) -> void:
	for i in range(segment_angles.size()):
		segment_angles[i] = angle + PI

func get_segment_position(segment: int, angle_offset: float, radius_offset: float) -> Vector2:
	var angle: float = get_segment_rotation(segment) + angle_offset
	return segment_positions[segment] + (Vector2(cos(angle), sin(angle)) * radius_offset)

func get_segment_rotation(segment: int) -> float:
	if segment == 0:
		return segment_positions[segment + 1].angle_to_point(segment_positions[segment])
	else:
		return segment_positions[segment].angle_to_point(segment_positions[segment - 1]) + PI

func interpolate_polygon(polygon: Array[Vector2], detalisation: int) -> Array[Vector2]:
	var result: Array[Vector2]
	var detalisation_f := detalisation as float
	polygon.append(polygon[0])
	polygon.append(polygon[1])
	for i in range(polygon.size() - 2):
		for j in detalisation:
			var t: float = (j + 2) / (detalisation_f + 4)
			result.append(quadratic_bezier(polygon[i], polygon[i + 1], polygon[i + 2], t))
	return result

func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r
