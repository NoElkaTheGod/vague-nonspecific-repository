class_name Player extends RigidBody2D

var move_cd := 0
var fire_cd := 0
var angular_velocity_target := 0.0
@onready var thrust_sound_emitter := $ThrustSoundEmitter
@onready var thruster_particles := $ThrusterParticles
@onready var shot_sound_emitter := $ShotSoundEmitter
@onready var shot_particles := $ShotParticles
@onready var death_sound_emitter := $DeathSoundEmitter
@onready var death_particles := $DeathParticles
@onready var collision_sound_emitter := $CollisionSoundEmitter
@onready var idle_projectile_manager: IdleProjectileManager = get_parent().get_node("IdleProjectileManager")
@onready var game_manager: GameManager = get_parent()
@export var player: int

func _ready() -> void:
	$Area2D.connect("body_entered", fucking_die)

func init(number: int) -> void:
	player = number
	$Sprite2D.texture = AtlasTexture.new()
	$Sprite2D.texture.atlas = load("res://sprites/player.png")
	$Sprite2D.texture.region = Rect2(number * 48, 0, 48, 48)

func _process(_delta: float) -> void:
	if Input.is_action_pressed("Player" + str(player) + "Left"):
		angular_velocity_target = -5
	elif Input.is_action_pressed("Player" + str(player) + "Right"):
		angular_velocity_target = 5
	else:
		angular_velocity_target = 0
	angular_velocity = lerp(angular_velocity, angular_velocity_target, 0.04)
	if Input.is_action_pressed("Player" + str(player) + "Move") and move_cd == 0:
		linear_velocity += Vector2(cos(rotation), sin(rotation)) * 100
		thrust_sound_emitter.play()
		move_cd = 10
	elif move_cd > 0:
		move_cd -= 1
	if Input.is_action_pressed("Player" + str(player) + "Fire") and fire_cd == 0:
		fire()
		linear_velocity += Vector2(cos(rotation), sin(rotation)) * -200
		fire_cd = 80
	elif fire_cd > 0:
		fire_cd -= 1
	thruster_particles.emitting = Input.is_action_pressed("Player" + str(player) + "Move")

func _physics_process(_delta: float) -> void:
	linear_velocity = game_manager.account_for_attractors(linear_velocity, position, 1)
	if get_contact_count() > 0:
		collision_sound_emitter.play()

func fire() -> void:
	shot_sound_emitter.play()
	shot_particles.emitting = true
	var proj = idle_projectile_manager.get_idle_projectile()
	proj.init()
	proj.visible = true
	proj.process_mode = Node.PROCESS_MODE_PAUSABLE
	proj.position = position + (Vector2(cos(rotation), sin(rotation)) * 50)
	proj.velocity = (Vector2(cos(rotation), sin(rotation)) * 600) + linear_velocity

func fucking_die(body: Node2D) -> void:
	if body is not projectile: return
	death_sound_emitter.play()
	death_particles.emitting = true
	shot_particles.queue_free()
	thruster_particles.queue_free()
	$Sprite2D.visible = false
	call_deferred("KYS")

func KYS():
	process_mode = PROCESS_MODE_DISABLED
