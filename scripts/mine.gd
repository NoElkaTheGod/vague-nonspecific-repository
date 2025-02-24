class_name Mine extends RigidBody2D

var idle_projectile_manager: IdleProjectileManager
var activation_timer := 30
var explosion_timer := -1
var damage := 30
var components: Array[Node]
@onready var game_manager = get_parent().get_parent()
@onready var activation_area: Area2D = $Area2D
@onready var area_sprite: Sprite2D = $Explosion
@onready var sprite: Sprite2D = $Sprite2D
@onready var scary: Sprite2D = $ScaryRedCircle

func init() -> void:
	damage = 30
	activation_timer = 30
	explosion_timer = -1
	area_sprite.modulate = Color(1, 1, 1, 0)
	scary.visible = false

func activate() -> void:
	if explosion_timer != -1: return
	if activation_timer > 0: return
	$ActivationSound.play()
	scary.visible = false
	explosion_timer = 60

func explode() -> void:
	$ActivationSound.stop()
	for body in activation_area.get_overlapping_bodies():
		if body is Player:
			body.take_damage(self, damage)
		if body is Mine:
			body.activate()
	idle_projectile_manager.spawn_mine_remainder(position)
	idle_projectile_manager.add_idle_mine(self)

func _process(delta: float) -> void:
	area_sprite.rotate(PI * delta * 2)

func _physics_process(_delta: float) -> void:
	linear_velocity = game_manager.account_for_attractors(linear_velocity, position, 10)
	linear_velocity = linear_velocity.lerp(Vector2.ZERO, 0.03)
	for body in activation_area.get_overlapping_bodies():
		if body is Player:
			activate()
	if activation_timer == 1: scary.visible = true
	if activation_timer > 0: activation_timer -= 1
	if explosion_timer == -1: return
	explosion_timer -= 1
	area_sprite.modulate = Color(1, 1, 1, (60 - explosion_timer) / 60.0)
	sprite.position = Vector2(randf_range(-5, 5), randf_range(-5, 5))
	if explosion_timer == 0: explode()
