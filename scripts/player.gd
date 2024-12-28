class_name Player extends RigidBody2D

var move_cd := 0
var fire_cd := 0
var death_timer := -1
var angular_velocity_target := 0.0
@onready var sprite := $Sprite2D
@onready var thrust_sound_emitter := $ThrustSoundEmitter
@onready var thruster_particles := $ThrusterParticles
@onready var shot_sound_emitter := $ShotSoundEmitter
@onready var shot_particles := $ShotParticles
@onready var death_sound_emitter := $DeathSoundEmitter
@onready var alarm_sound_emitter := $AlarmSoundEmitter
@onready var death_particles := $DeathParticles
@onready var collision_sound_emitter: CollisionSoundEmitter = $CollisionSoundEmitter
@onready var idle_projectile_manager: IdleProjectileManager = get_parent().get_node("IdleProjectileManager")
@onready var game_manager: GameManager = get_parent()
@export var player: int

func _ready() -> void:
	$Area2D.connect("body_entered", start_dying)

func init(number: int) -> void:
	player = number
	$Sprite2D.texture = AtlasTexture.new()
	$Sprite2D.texture.atlas = load("res://sprites/player.png")
	$Sprite2D.texture.region = Rect2(number * 48, 0, 48, 48)

func _physics_process(_delta: float) -> void:
	linear_velocity = game_manager.account_for_attractors(linear_velocity, position, 1)
	if get_contact_count() > 0:
		handle_collisions()
	if death_timer != -1:
		sprite.position = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		if death_timer == 0:
			fucking_die(null)
		death_timer -= 1
		return
	if Input.is_action_pressed("Player" + str(player) + "Left"):
		angular_velocity_target = -5
	elif Input.is_action_pressed("Player" + str(player) + "Right"):
		angular_velocity_target = 5
	else:
		angular_velocity_target = 0
	var joystick_direction := Vector2(Input.get_joy_axis(player, JOY_AXIS_LEFT_X), Input.get_joy_axis(player, JOY_AXIS_LEFT_Y))
	if (joystick_direction != Vector2.ZERO):
		var target_direction: float = joystick_direction.angle()
		if rotation - 0.4 > target_direction and rotation - 4.0 < target_direction or rotation + 2.5 < target_direction:
			angular_velocity_target = -5
		elif rotation + 0.4 < target_direction or rotation - 2.5 > target_direction:
			angular_velocity_target = 5
	angular_velocity = move_toward(angular_velocity, angular_velocity_target, 0.5)
	if Input.is_action_pressed("Player" + str(player) + "Move") and move_cd == 0:
		linear_velocity += Vector2(cos(rotation), sin(rotation)) * 100
		thrust_sound_emitter.play()
		move_cd = 5
	elif move_cd > 0:
		move_cd -= 1
	if Input.is_action_pressed("Player" + str(player) + "Fire") and fire_cd == 0:
		fire()
		linear_velocity += Vector2(cos(rotation), sin(rotation)) * -200
		fire_cd = 40
	elif fire_cd > 0:
		fire_cd -= 1
	thruster_particles.emitting = Input.is_action_pressed("Player" + str(player) + "Move")

func handle_collisions() -> void:
	if get_colliding_bodies()[0] is StaticBody2D:
		collision_sound_emitter.play(0)
		if get_colliding_bodies()[0].get_child(0).shape is WorldBoundaryShape2D:
			linear_velocity += get_colliding_bodies()[0].get_child(0).shape.normal * 50
		return
	if get_colliding_bodies()[0] is RigidBody2D:
		var achtung = get_colliding_bodies()[0] as RigidBody2D
		if (achtung.linear_velocity + linear_velocity).length() < 600.0 and (achtung.linear_velocity.length() + linear_velocity.length()) > 900.0:
			start_dying()
			collision_sound_emitter.play(3)
		elif (achtung.linear_velocity + linear_velocity).length() < 900.0 and (achtung.linear_velocity.length() + linear_velocity.length()) > 500.0:
			collision_sound_emitter.play(2)
			angular_velocity += pow(randf_range(-5, 5), 2)
		else:
			collision_sound_emitter.play(1)
			angular_velocity += pow(randf_range(-3, 3), 2)

func start_dying(_body: Node2D = null):
	if death_timer != -1: return
	alarm_sound_emitter.play()
	death_timer = 75

func fire() -> void:
	shot_sound_emitter.play()
	shot_particles.emitting = true
	var proj = idle_projectile_manager.get_idle_projectile()
	proj.init()
	proj.visible = true
	proj.process_mode = Node.PROCESS_MODE_PAUSABLE
	proj.position = position + (Vector2(cos(rotation), sin(rotation)) * 50)
	proj.velocity = (Vector2(cos(rotation), sin(rotation)) * 600)

func fucking_die(_body: Node2D) -> void:
	death_sound_emitter.play()
	death_particles.emitting = true
	shot_particles.queue_free()
	thruster_particles.queue_free()
	$Sprite2D.visible = false
	call_deferred("KYS")

func KYS():
	process_mode = PROCESS_MODE_DISABLED
