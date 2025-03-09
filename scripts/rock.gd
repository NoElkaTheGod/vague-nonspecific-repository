class_name Rock extends RigidBody2D

@onready var game_manager: GameManager = get_node("/root/GameManager")
@onready var health_component := $HealthComponent

func _physics_process(_delta: float) -> void:
	linear_velocity = game_manager.account_for_attractors(linear_velocity, position, 0.3)
	for body in get_colliding_bodies():
		if body is StaticBody2D:
			if body.get_node("CollisionShape2D").shape is WorldBoundaryShape2D:
				linear_velocity += body.get_node("CollisionShape2D").shape.normal * 100

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	for i in range(state.get_contact_count()):
		if state.get_contact_collider_object(i) is StaticBody2D:
			var collision_speed_coefficient: float = linear_velocity.length() * 0.02
			var collision_direction_coefficient: float = linear_velocity.normalized().dot(state.get_contact_local_normal(i))
			var collision_severity = collision_speed_coefficient * collision_direction_coefficient
			if collision_severity >= 5.0: health_component.take_damage(state.get_contact_collider_object(i), collision_severity)
			continue
		if state.get_contact_collider_object(i) is RigidBody2D:
			var collision_speed_coefficient: float = (state.get_contact_collider_object(i).linear_velocity - linear_velocity).length() * 0.04
			var collision_mass_coefficient: float = sqrt(state.get_contact_collider_object(i).mass / mass)
			var collision_severity = collision_speed_coefficient * collision_mass_coefficient
			health_component.take_damage(state.get_contact_collider_object(i), collision_severity)
