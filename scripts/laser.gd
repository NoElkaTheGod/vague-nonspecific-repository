class_name Laser extends Node2D

@onready var ray := $RayCast2D
@onready var line := $Line2D
@onready var hit := $Sprite2D
@onready var sound := $AudioStreamPlayer
@onready var particles := $Sprite2D/GPUParticles2D

var damage = 15
var components: Array[Node]

func activate() -> void:
	sound.play()
	ray.force_raycast_update()
	hit.global_rotation = ray.get_collision_normal().angle()
	hit.global_position = ray.get_collision_point()
	particles.emitting = true
	line.points[1].x = (ray.get_collision_point() - position).length()
	var collision: Node = ray.get_collider()
	if collision.has_node("HealthComponent"):
		collision.get_node("HealthComponent").take_damage(hit, damage)
	elif collision is RigidBody2D:
		collision.linear_velocity += ray.get_collision_normal().rotated(PI) * 50

func _process(delta: float) -> void:
	line.width -= delta * 20
	hit.modulate = Color(1, 1, 1, hit.modulate.a - delta * 2)
	if line.width <= 0:
		queue_free()
