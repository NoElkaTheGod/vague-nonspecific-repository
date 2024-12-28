class_name Rock extends RigidBody2D

@onready var game_manager: GameManager = get_parent()
@onready var collision_sound_emitter := $WorldBound

func _physics_process(_delta: float) -> void:
	linear_velocity = game_manager.account_for_attractors(linear_velocity, position, 0.7)
	if get_contact_count() == 0: return
	if get_colliding_bodies()[0] is StaticBody2D:
		collision_sound_emitter.play()
		if get_colliding_bodies()[0].get_child(0).shape is WorldBoundaryShape2D:
			linear_velocity += get_colliding_bodies()[0].get_child(0).shape.normal * 100
