class_name Player extends RigidBody2D

var move_cd := 0
var fire_cd := 0
var max_move_cd := 5
var turn_speed := 6
var charging := false
var charge_cap := 0
var death_timer := -1
var angular_velocity_target := 0.0
var active_powerup_type := -1
var active_powerup_uses := 0
var shitty_powerup_time_table: Dictionary = {0 : 30, 1: 5, 2: 1}
@onready var sprite := $Sprite2D
@onready var thrust_sound_emitter := $ThrustSoundEmitter
@onready var thruster_particles := $ThrusterParticles
@onready var shot_sound_emitter := $ShotSoundEmitter
@onready var death_sound_emitter := $DeathSoundEmitter
@onready var alarm_sound_emitter := $AlarmSoundEmitter
@onready var powerup_sound_emitter := $PowerupSoundEmitter
@onready var chargeup_sound_emitter := $ChargeupSoundEmitter
@onready var caboom_sound_emitter := $CaboomSoundEmitter
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
		angular_velocity_target = -turn_speed
	elif Input.is_action_pressed("Player" + str(player) + "Right"):
		angular_velocity_target = turn_speed
	else:
		angular_velocity_target = 0
	var joystick_direction := Vector2(Input.get_joy_axis(player, JOY_AXIS_LEFT_X), Input.get_joy_axis(player, JOY_AXIS_LEFT_Y))
	if (joystick_direction != Vector2.ZERO):
		var target_direction: float = joystick_direction.angle()
		if rotation - 0.4 > target_direction and rotation - 4.0 < target_direction or rotation + 2.5 < target_direction:
			angular_velocity_target = -turn_speed
		elif rotation + 0.4 < target_direction or rotation - 2.5 > target_direction:
			angular_velocity_target = turn_speed
	angular_velocity = move_toward(angular_velocity, angular_velocity_target, 0.5)
	if Input.is_action_pressed("Player" + str(player) + "Move") and move_cd == 0:
		linear_velocity += Vector2(cos(rotation), sin(rotation)) * 100
		thrust_sound_emitter.play()
		move_cd = max_move_cd
	elif move_cd > 0:
		move_cd -= 1
	if active_powerup_uses == 0: active_powerup_type = -1
	if charging:
		charge_cap -= 1
		if charge_cap == 0:
			chargeup_sound_emitter.stop()
			caboom_sound_emitter.play()
			$Explosion.stop_anim()
			charging = false
			fire_cd = 60
			max_move_cd = 5
			turn_speed = 5
	elif Input.is_action_pressed("Player" + str(player) + "Fire") and fire_cd == 0:
		match active_powerup_type:
			-1:
				fire_cd = 40
				fire(1)
				linear_velocity += Vector2(cos(rotation), sin(rotation)) * -200
			0:
				fire_cd = 7
				fire(1)
				linear_velocity += Vector2(cos(rotation), sin(rotation)) * -100
				active_powerup_uses -= 1
			1:
				fire_cd = 50
				fire(9)
				linear_velocity += Vector2(cos(rotation), sin(rotation)) * -400
				active_powerup_uses -= 1
			2:
				active_powerup_uses -= 1
				chargeup_sound_emitter.play()
				charging = true
				charge_cap = 240
				max_move_cd = 3
				turn_speed = 7
				$Explosion.start_anim(240)
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
		if (achtung.linear_velocity + linear_velocity).length() < 900.0 and (achtung.linear_velocity.length() + linear_velocity.length()) > 900.0:
			collision_sound_emitter.play(3)
			#start_dying()
		elif (achtung.linear_velocity + linear_velocity).length() < 1500.0 and (achtung.linear_velocity.length() + linear_velocity.length()) > 500.0:
			collision_sound_emitter.play(2)
			angular_velocity += pow(randf_range(-5, 5), 2)
		else:
			collision_sound_emitter.play(1)
			angular_velocity += pow(randf_range(-3, 3), 2)

func start_dying(_body: Node2D = null):
	if death_timer != -1: return
	if charging: return
	alarm_sound_emitter.play()
	death_timer = 75

func fire(amount: int) -> void:
	if idle_projectile_manager == null: return
	shot_sound_emitter.play()
	var additional_rotation: Array[float]
	additional_rotation.resize(amount)
	for i in range(amount):
		additional_rotation[i] = deg_to_rad(((i - (amount / 2.0 - 0.5)) * 10))
	for i in range(amount):
		var proj = idle_projectile_manager.get_idle_projectile()
		proj.init()
		proj.visible = true
		proj.process_mode = Node.PROCESS_MODE_PAUSABLE
		proj.position = position + (Vector2(cos(rotation), sin(rotation)) * 50)
		proj.velocity = (Vector2(cos(rotation + additional_rotation[i]), sin(rotation + additional_rotation[i])) * randf_range(550, 650)) + linear_velocity

func fucking_die(_body: Node2D) -> void:
	death_sound_emitter.play()
	death_particles.emitting = true
	thruster_particles.queue_free()
	$Sprite2D.visible = false
	call_deferred("KYS")
	game_manager.im_dead_lol(self)

func KYS():
	process_mode = PROCESS_MODE_DISABLED

func apply_powerup(powerup_type: int) -> void:
	powerup_sound_emitter.play()
	active_powerup_uses = shitty_powerup_time_table[powerup_type]
	active_powerup_type = powerup_type
