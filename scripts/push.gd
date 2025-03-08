class_name Push extends Node2D

@onready var area := $Area2D
@onready var shape := $Area2D/CollisionShape2D
@onready var sprite := $Area2D/Sprite2D
@onready var particles := $Area2D/GPUParticles2D
@onready var sound := $AudioStreamPlayer

var radius := 50.0
var power := 120.0
var origin_position := Vector2.ZERO

func activate() -> void:
	shape.shape.radius = ceili(radius)
	area.position.x = radius
	sprite.scale.x = radius / 100
	sprite.scale.y = sprite.scale.x
	particles.scale.x = radius / 100
	particles.scale.y = particles.scale.x
	particles.emitting = true
	sound.play()

var timer := 30

func _physics_process(_delta: float) -> void:
	timer -= 1
	if timer >= 20:
		for item in area.get_overlapping_bodies():
			if item is CharacterBody2D:
				item.velocity += Vector2.RIGHT.rotated(rotation).normalized() * power
			elif item is RigidBody2D:
				item.linear_velocity += Vector2.RIGHT.rotated(rotation).normalized() * power
	else:
		sprite.modulate.a -= 0.05
		if timer == 0:
			free()
