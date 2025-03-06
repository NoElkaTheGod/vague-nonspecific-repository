class_name chaotic_trajectory_component extends BaseComponent

var parent: CharacterBody2D
var anomaly: float = randf_range(-2, 2)

func _ready() -> void:
	var node = get_parent()
	if node is not CharacterBody2D:
		process_mode = PROCESS_MODE_DISABLED
		return
	parent = node

func _physics_process(delta: float) -> void:
	parent.velocity = parent.velocity.rotated(anomaly * delta)
	anomaly = lerp(anomaly, 0.0, 0.1)
