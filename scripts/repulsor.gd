class_name Repulsor extends Area2D

@onready var particle_processor: ParticleProcessMaterial = $GPUParticles2D.process_material
var power: int = -50

func init(power_set: int) -> void:
	power = power_set
	$AnimatedSprite2D.play()
