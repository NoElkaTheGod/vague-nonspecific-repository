class_name Rock extends RigidBody2D

@onready var game_manager: GameManager = get_parent().get_parent().get_parent()

func _physics_process(_delta: float) -> void:
	linear_velocity = game_manager.account_for_attractors(linear_velocity, position, 0.3)
	if get_contact_count() == 0: return
	if get_colliding_bodies()[0] is StaticBody2D:
		if get_colliding_bodies()[0].get_node("CollisionShape2D").shape is WorldBoundaryShape2D:
			linear_velocity += get_colliding_bodies()[0].get_node("CollisionShape2D").shape.normal * 100
