class_name Repulsor extends Area2D

@onready var particle_processor: ParticleProcessMaterial = $GPUParticles2D.process_material
@export var power: int

func _ready() -> void:
	$AnimatedSprite2D.play()
