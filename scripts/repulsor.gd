class_name Repulsor extends Area2D

@onready var particle_processor: ParticleProcessMaterial = $GPUParticles2D.process_material
var power: int = -50
var linked_attractor: Attractor

func init(power_set: int, link: Attractor) -> void:
	power = power_set
	linked_attractor = link
