class_name projectile extends PhysicsBody2D

var idle_projectile_manager: IdleProjectileManager
var velocity := Vector2.ZERO
var damage := 20.0
var components: Array[Node]
var timer := 300
@onready var game_manager = get_parent().get_parent()
@onready var sound := $SoundEmitter

func init() -> void:
	timer = 300
	damage = 20
	sound.play()
	for exception in get_collision_exceptions():
		remove_collision_exception_with(exception)

func _process(_delta: float) -> void:
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	timer -= 1
	velocity = game_manager.account_for_attractors(velocity, position, 10)
	var collision := move_and_collide(velocity * delta)
	if collision != null or timer <= 0:
		idle_projectile_manager.spawn_bullet_remainder(position)
		idle_projectile_manager.add_idle_projectile(self)
		if collision == null: return
		if collision.get_collider() is Player:
			collision.get_collider().take_damage(self, damage)
