class_name projectile extends PhysicsBody2D

var idle_projectile_manager: IdleProjectileManager
var timer := 60
var velocity := Vector2.ZERO
@onready var game_manager = get_parent().get_parent()

func init() -> void:
	timer = 60

func _process(_delta: float) -> void:
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	velocity = game_manager.account_for_attractors(velocity, position, 10)
	var collision := move_and_collide(velocity * delta)
	if velocity.length() <= 100:
		timer -= 1
	if collision != null or timer <= 0:
		idle_projectile_manager.spawn_bullet_remainder(position)
		idle_projectile_manager.add_idle_projectile(self)
