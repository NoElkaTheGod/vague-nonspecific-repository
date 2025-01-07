extends StaticBody2D

@export var rotation_speed: float
func _physics_process(delta: float) -> void:
	rotate(delta * deg_to_rad(rotation_speed))
