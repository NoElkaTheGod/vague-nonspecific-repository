class_name chaotic_trajectory_component extends Node

var parent: CharacterBody2D
var anomaly: float = randf_range(-1, 1)

func _ready() -> void:
	var node = get_parent()
	if node is not CharacterBody2D:
		process_mode = PROCESS_MODE_DISABLED
		return
	parent = node

func _physics_process(delta: float) -> void:
	parent.velocity = parent.velocity.rotated(anomaly * delta)
