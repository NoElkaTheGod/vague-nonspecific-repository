class_name Rock extends RigidBody2D

@onready var game_manager: GameManager = get_node("/root/GameManager")

func _physics_process(_delta: float) -> void:
	linear_velocity = game_manager.account_for_attractors(linear_velocity, position, 0.3)
	for body in get_colliding_bodies():
		if body is StaticBody2D:
			if body.get_node("CollisionShape2D").shape is WorldBoundaryShape2D:
				linear_velocity += body.get_node("CollisionShape2D").shape.normal * 100
