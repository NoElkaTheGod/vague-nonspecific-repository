class_name ProjectileBase extends PhysicsBody2D

var remainder_scene: PackedScene = load("res://scenes/bullet_remainder.tscn")
var velocity := Vector2.ZERO
var damage := 20.0
var components: Array[Node]
var timer := 300
@onready var game_manager: GameManager = get_parent().get_parent()
@onready var sound := $SoundEmitter

func init() -> void:
	timer = 300
	damage = 20
	sound.play()

func _process(_delta: float) -> void:
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	timer -= 1
	velocity = game_manager.account_for_attractors(velocity, position, 10)
	custom_process_behaviour(delta)
	var collision := move_and_collide(velocity * delta)
	if collision != null or timer <= 0:
		var remainder = remainder_scene.instantiate()
		remainder.position = position
		game_manager.projectile_container.add_child(remainder)
		queue_free()
		if collision == null: return
		custom_collision_behaviour(collision)
		if collision.get_collider().has_node("HealthComponent"):
			collision.get_collider().get_node("HealthComponent").take_damage(self, damage)

func custom_process_behaviour(_delta: float) -> void:
	return

func custom_collision_behaviour(_collision: KinematicCollision2D) -> void:
	return
