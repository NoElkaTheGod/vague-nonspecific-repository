extends Node2D

@export var timer := 30

func _ready() -> void:
	$AudioStreamPlayer.play()
	$GPUParticles2D.emitting = true

func _process(_delta: float) -> void:
	if timer == 0: queue_free()
	timer -= 1
