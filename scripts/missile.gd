class_name Missile extends PhysicsBody2D

var idle_projectile_manager: IdleProjectileManager
var velocity := Vector2.ZERO
var damage := 20
var you_have_to_kill_yourself := false
@onready var game_manager = get_parent().get_parent()

func init() -> void:
	damage = 20
	you_have_to_kill_yourself = false

func _process(_delta: float) -> void:
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	velocity = game_manager.account_for_attractors(velocity, position, 10)
	velocity *= 1.05
	var collision := move_and_collide(velocity * delta)
	if collision != null or you_have_to_kill_yourself:
		idle_projectile_manager.spawn_missile_remainder(position)
		idle_projectile_manager.add_idle_missile(self)
		var sas = get_node("Area2D") as Area2D
		for body in sas.get_overlapping_bodies():
			if body is RigidBody2D:
				body.linear_velocity += (body.position - position).normalized() * 100
			if body is Player:
				body.start_dying(self, 10)
