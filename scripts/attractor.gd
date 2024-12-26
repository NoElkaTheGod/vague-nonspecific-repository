class_name Attractor extends Area2D

@onready var particle_processor: ParticleProcessMaterial = $GPUParticles2D.process_material
@onready var sound = $AudioStreamPlayer
var power: int = 50
var linked_repulsor: Repulsor

func _ready() -> void:
	connect("body_entered", teleprot)

func init(power_set: int, link: Repulsor) -> void:
	power = power_set
	linked_repulsor = link

func teleprot(body: Node2D) -> void:
	body.global_position = linked_repulsor.global_position + (global_position - body.global_position)
	sound.play()
