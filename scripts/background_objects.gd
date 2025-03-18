@tool
extends Node

const SIM_SPEED = 0.1
const SCALE_OFFSET_RATIO = 0.5
const DEF_ORBIT_LENGTH = 1000.0

@export var parallaxes: Array[Parallax2D]
@export var sprites: Array[Sprite2D]
@export var orbit_sizes: Array[Vector3]

var orbit_offsets: Array[float]
var orbit_speeds: Array[float]
var counters: Array[float]

func _ready() -> void:
	$Node2D.position = $Node2D.get_viewport_rect().size / 2.0
	for i in range(sprites.size()):
		orbit_offsets.append(randf_range(0, 2 * PI))
		orbit_speeds.append(DEF_ORBIT_LENGTH / orbit_sizes[i].length())
		counters.append(0)
		var rand = randf_range(-1, 1)
		parallaxes[i].rotation = rand
		sprites[i].rotation = -rand

func _process(delta: float) -> void:
	for i in range(sprites.size()):
		orbit_speeds[i] = DEF_ORBIT_LENGTH / orbit_sizes[i].length()
		counters[i] += wrapf(delta * orbit_speeds[i] * SIM_SPEED, 0, PI * 2)
		sprites[i].position = Vector2(cos(counters[i] + orbit_offsets[i]) * orbit_sizes[i].x, sin(counters[i] + orbit_offsets[i]) * orbit_sizes[i].y)
		sprites[i].scale.x = lerp(1.0, 0.1, (sin(counters[i] + orbit_offsets[i]) + 1) / 2.0 * orbit_sizes[i].z)
		sprites[i].scale.y = sprites[i].scale.x
		parallaxes[i].scroll_scale.x = lerp(0.6, 0.1, (sin(counters[i] + orbit_offsets[i]) + 1) / 2.0 * orbit_sizes[i].z)
		parallaxes[i].scroll_scale.y = parallaxes[i].scroll_scale.x
