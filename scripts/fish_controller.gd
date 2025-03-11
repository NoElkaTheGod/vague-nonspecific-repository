@tool
class_name FishController extends Node

var segments: Array[BodySegment]
var segment_lengths: Array[float]
var parts: Dictionary[String, Node2D]
@export var proxy_body: Node

const SEGMENT_PADDING = 2

@onready var physics_container: Node = $PhysicsContainer
@onready var visual_polygon: Polygon2D = $BodyPolygon
@onready var parts_container: Node = $PartsContainer

func _ready() -> void:
	for child in physics_container.get_children():
		#child.proxy_body = proxy_body
		segments.append(child)
		segment_lengths.append(child.get_child(0).shape.radius + SEGMENT_PADDING)
	for i in segments:
		for j in segments:
			if i == j: continue
			i.add_collision_exception_with(j)
	for part in parts_container.get_children():
		parts.set(part.name, part)

const MAX_SEGMENT_ANGLE = deg_to_rad(30)

func _physics_process(_delta: float) -> void:
	for i in range(1, segments.size()):
		var prev_seg_pos: Vector2 = segments[i - 1].position
		var cur_seg_pos: Vector2 = segments[i].position
		var prev_seg_size: float = segment_lengths[i - 1]
		segments[i].position = ((cur_seg_pos - prev_seg_pos).normalized() * prev_seg_size) + prev_seg_pos
		if i < segments.size() - 1:
			var next_seg_pos: Vector2 = segments[i + 1].position
			segments[i].rotation = prev_seg_pos.angle_to_point(next_seg_pos)
		segments[i].position = segments[i].position.lerp(Vector2(cos(segments[i - 1].rotation), sin(segments[i - 1].rotation)) * prev_seg_size + prev_seg_pos, 0.5)

const HEAD_VERTICIES = 7
const TAIL_VERTICIES = 5

func _process(_delta: float) -> void:
	var polygon: Array[Vector2]
	var polygon_left: Array[Vector2]
	var polygon_right: Array[Vector2]
	var polygon_head: Array[Vector2]
	var polygon_tail: Array[Vector2]
	for i in range(HEAD_VERTICIES + 1):
		var angle: float = -(PI / 2) + ((PI / HEAD_VERTICIES) * i)
		polygon_head.append(get_segment_position(0, angle, segment_lengths[0]))
	for i in range(TAIL_VERTICIES + 1):
		var angle: float = -(PI / 2) + (PI / TAIL_VERTICIES * i)
		polygon_tail.append(get_segment_position(segments.size() - 1, angle, segment_lengths[-1]))
	for i in range(1, segments.size() - 1):
		polygon_right.append(get_segment_position(i, - PI / 2, segment_lengths[i]))
		polygon_left.append(get_segment_position(i, PI / 2, segment_lengths[i]))
	polygon_left.reverse()
	polygon.append_array(polygon_head)
	polygon.append_array(polygon_right)
	polygon.append_array(polygon_tail)
	polygon.append_array(polygon_left)
	visual_polygon.polygon = interpolate_polygon(polygon, 4)
	parts.get("EyeLeft").position = get_segment_position(0, PI / 2, 8)
	parts.get("EyeRight").position = get_segment_position(0, -PI / 2, 8)
	parts.get("FinLeft").position = get_segment_position(2, PI / 2, 20)
	parts.get("FinRight").position = get_segment_position(2, -PI / 2, 20)
	parts.get("FinTail").position = get_segment_position(segments.size() - 1, 0, 5)
	parts.get("FinLeft").rotation = get_segment_rotation(2)
	parts.get("FinRight").rotation = get_segment_rotation(2)
	parts.get("FinTail").rotation = get_segment_rotation(segments.size() - 1)

func set_position(position: Vector2) -> void:
	segments[0].position = position

func set_head_rotation(angle: float) -> void:
	segments[0].rotation = angle + PI

func set_complete_rotation(angle: float) -> void:
	for segment in segments:
		segment.rotation = angle + PI

func get_segment_position(segment: int, angle_offset: float, radius_offset: float) -> Vector2:
	var angle: float = get_segment_rotation(segment) + angle_offset
	return segments[segment].position + (Vector2(cos(angle), sin(angle)) * radius_offset)

func get_segment_rotation(segment: int) -> float:
	if segment == 0:
		return segments[segment + 1].position.angle_to_point(segments[segment].position)
	else:
		return segments[segment].position.angle_to_point(segments[segment - 1].position) + PI

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
