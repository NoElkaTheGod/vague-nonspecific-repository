class_name projectile extends PhysicsBody2D

var idle_projectile_manager: IdleProjectileManager
var velocity := Vector2.ZERO
var damage := 10.0
var components: Array[Node]
@onready var game_manager = get_parent().get_parent()
@onready var sound := $SoundEmitter

func init() -> void:
	damage = 10
	sound.play()

func _process(_delta: float) -> void:
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	velocity = game_manager.account_for_attractors(velocity, position, 10)
	var collision := move_and_collide(velocity * delta)
	if collision != null:
		idle_projectile_manager.spawn_bullet_remainder(position)
		idle_projectile_manager.add_idle_projectile(self)
		if collision.get_collider() is Player:
			collision.get_collider().take_damage(self, damage)
