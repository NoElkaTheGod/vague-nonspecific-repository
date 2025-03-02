class_name Missile extends PhysicsBody2D

var idle_projectile_manager: IdleProjectileManager
var velocity := Vector2.ZERO
var damage := 20.0
var target_velocity := 1100.0
var components: Array[Node]
@onready var game_manager = get_parent().get_parent()
@onready var sound := $SoundEmitter

func init() -> void:
	damage = 20
	target_velocity = 1100
	sound.play()
	for exception in get_collision_exceptions():
		remove_collision_exception_with(exception)

func _process(_delta: float) -> void:
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	velocity = game_manager.account_for_attractors(velocity, position, 10)
	velocity = velocity.lerp(velocity.normalized() * target_velocity, 0.05)
	var collision := move_and_collide(velocity * delta)
	if collision != null:
		if collision.get_collider() is Player:
			collision.get_collider().take_damage(self, damage)
		var sas = get_node("Area2D") as Area2D
		for body in sas.get_overlapping_bodies():
			if body is RigidBody2D:
				body.linear_velocity += (body.position - position).normalized() * 300
			if body is Player:
				body.take_damage(self, damage / 2.0)
		idle_projectile_manager.spawn_missile_remainder(position)
		idle_projectile_manager.add_idle_missile(self)
