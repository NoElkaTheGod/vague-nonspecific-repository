class_name Attractor extends Area2D

@onready var particle_processor: ParticleProcessMaterial = $GPUParticles2D.process_material
@onready var sound = $AudioStreamPlayer
var power: int = 50

func _ready() -> void:
	connect("body_entered", contact)

func init(power_set: int) -> void:
	power = power_set
	$AnimatedSprite2D.play()

func contact(body: Node2D) -> void:
	if body is not RigidBody2D: return
	var pebis := body as RigidBody2D
	pebis.linear_velocity = (pebis.position - position) * 50 / pebis.mass
	pebis.angular_velocity += 50 / pebis.mass
	sound.play()
