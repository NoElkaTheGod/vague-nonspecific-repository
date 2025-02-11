class_name Player extends RigidBody2D

var hit_points := 0
var type_hit_points := [3, 2, 6, 1]
var is_player_active := false
var is_input_connected := false
var is_round_going := false
var is_spawning := false
var move_cd := 0
var fire_cd := 0
var max_move_cd := [5, 6, 8, 3]
var turn_speed := [5, 5, 3, 6]
var death_timer := -1
var alive := false
var angular_velocity_target := 0.0
@onready var sprite := $Sprite2D
@onready var thrust_sound_emitter := $ThrustSoundEmitter
@onready var thruster_particles := $ThrusterParticles
@onready var shot_sound_emitter := $ShotSoundEmitter
@onready var mine_release_sound_emitter := $MineReleaseSoundEmitter
@onready var death_sound_emitter := $DeathSoundEmitter
@onready var death_particles := $DeathParticles
@onready var alarm_sound_emitter := $AlarmSoundEmitter
@onready var collision_sound_emitter: CollisionSoundEmitter = $CollisionSoundEmitter
@onready var melee_hit_animation: AnimatedSprite2D = $MeleeHit/AnimatedSprite2D
@onready var melee_hit_sound_emitter := $MeleeHit/HitSoundEmitter
@onready var melee_swing_sound_emitter := $MeleeHit/SwingSoundEmitter
@onready var melee_parry_sound_emitter := $MeleeHit/ParrySoundEmitter
@onready var hurt_sound_emitter := $HurtSoundEmitter
@onready var melee_hit_area: Area2D = $MeleeHit/Area2D
@onready var idle_projectile_manager: IdleProjectileManager = get_parent().get_parent().get_node("IdleProjectileManager")
@onready var game_manager: GameManager = get_parent().get_parent()
var bound_player_selector: PlayerSelector
var input_device := -1
var character_color: int
var character_type: int
var menu_input_cd := 20

var inventory: Array[Action]
const action_stack_size := 8
const inventory_rows := 2

func set_active():
	is_player_active = true
	process_mode = PROCESS_MODE_INHERIT
	$Sprite2D.visible = true
	$ThrusterParticles.visible = true
	alive = true
	reset_player_state()

func set_inactive():
	is_player_active = false
	process_mode = PROCESS_MODE_DISABLED
	$Sprite2D.visible = false
	$ThrusterParticles.visible = false
	alive = false

func reset_player_state():
	$Sprite2D.position = Vector2(3, 0)
	$Sprite2D.rotation = deg_to_rad(90)
	$DeathParticles.position = Vector2(0, 0)
	thruster_particles.emitting = false
	angular_velocity = 0
	linear_velocity = Vector2.ZERO
	fire_cd = 60
	menu_input_cd = 20
	hit_points = type_hit_points[character_type]

func _ready() -> void:
	$Area2D.connect("body_entered", start_dying)
	$ThrusterParticles.visible = false
	$Sprite2D.visible = false
	melee_hit_animation.connect("animation_finished", hide_swing_animation)
	inventory.resize(action_stack_size * (inventory_rows + 1))
	test_fill_inv()

func test_fill_inv() -> void:
	inventory[0] = shot_item.new()
	add_child(inventory[0])
	inventory[1] = sword_item.new()
	add_child(inventory[1])

func bind_player_selector(node: PlayerSelector, lobby: bool = false) -> void:
	bound_player_selector = node
	node.yo_wassup(self, lobby)

func change_appearence():
	$Sprite2D.texture.region = Rect2(character_color * 48, character_type * 48, 48, 48)

func init(color: int, device: int) -> void:
	is_input_connected = true
	character_color = color
	input_device = device
	$Sprite2D.texture = AtlasTexture.new()
	$Sprite2D.texture.atlas = load("res://sprites/player.png")
	$Sprite2D.texture.region = Rect2(color * 48, 0, 48, 48)
	set_active()
	$SpawnSoundEmitter.play()
	game_manager.player_finished_initialisation(self)

func _physics_process(_delta: float) -> void:
	if is_spawning: return
	if not is_round_going:
		linear_velocity = Vector2.ZERO
		angular_velocity = PI
		if menu_input_cd > 0:
			menu_input_cd -= 1
		if bound_player_selector == null: return
		if Input.is_action_pressed("Player" + str(input_device) + "Fire"):
			if menu_input_cd == 0:
				bound_player_selector.fire_pressed()
				menu_input_cd = 20
			return
		if input_device <= 7:
			if Input.get_joy_axis(input_device,JOY_AXIS_LEFT_X) < -0.5:
				if menu_input_cd == 0:
					bound_player_selector.left_pressed()
					menu_input_cd = 20
				return
			if Input.get_joy_axis(input_device,JOY_AXIS_LEFT_X) > 0.5:
				if menu_input_cd == 0:
					bound_player_selector.right_pressed()
					menu_input_cd = 20
				return
			if Input.get_joy_axis(input_device,JOY_AXIS_LEFT_Y) > 0.5:
				if menu_input_cd == 0:
					bound_player_selector.up_pressed()
					menu_input_cd = 20
				return
			if Input.get_joy_axis(input_device,JOY_AXIS_LEFT_Y) < -0.5:
				if menu_input_cd == 0:
					bound_player_selector.down_pressed()
					menu_input_cd = 20
				return
			menu_input_cd = 0
			return
		else:
			if Input.is_action_pressed("Player" + str(input_device) + "Left"):
				if menu_input_cd == 0:
					bound_player_selector.left_pressed()
					menu_input_cd = 20
				return
			if Input.is_action_pressed("Player" + str(input_device) + "Right"):
				if menu_input_cd == 0:
					bound_player_selector.right_pressed()
					menu_input_cd = 20
				return
			if Input.is_action_pressed("Player" + str(input_device) + "Up"):
				if menu_input_cd == 0:
					bound_player_selector.up_pressed()
					menu_input_cd = 20
				return
			if Input.is_action_pressed("Player" + str(input_device) + "Down"):
				if menu_input_cd == 0:
					bound_player_selector.down_pressed()
					menu_input_cd = 20
				return
			menu_input_cd = 0
			return
	linear_velocity = game_manager.account_for_attractors(linear_velocity, position, 1)
	if get_contact_count() > 0:
		handle_collisions()
	if death_timer != -1:
		sprite.position = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		if death_timer == 0:
			fucking_die(null)
		death_timer -= 1
		return
	if input_device > 7:
		if Input.is_action_pressed("Player" + str(input_device) + "Left"):
			angular_velocity_target = -turn_speed[character_type]
		elif Input.is_action_pressed("Player" + str(input_device) + "Right"):
			angular_velocity_target = turn_speed[character_type]
		else:
			angular_velocity_target = 0
	else:
		var joystick_direction := Vector2(Input.get_joy_axis(input_device, JOY_AXIS_LEFT_X), Input.get_joy_axis(input_device, JOY_AXIS_LEFT_Y))
		if (joystick_direction != Vector2.ZERO):
			var target_direction: float = joystick_direction.angle()
			var direction_difference: float = wrapf(target_direction - rotation, -PI, PI)
			if abs(direction_difference) > 0.1:
				angular_velocity_target = sign(direction_difference) * turn_speed[character_type]
			else:
				angular_velocity_target = 0.0
		else:
			angular_velocity_target = 0.0
	angular_velocity = move_toward(angular_velocity, angular_velocity_target, 1.0)
	if Input.is_action_pressed("Player" + str(input_device) + "Move") and move_cd == 0:
		linear_velocity += Vector2(cos(rotation), sin(rotation)) * 70
		thrust_sound_emitter.play()
		move_cd = max_move_cd[character_type]
	elif move_cd > 0:
		move_cd -= 1
	if Input.is_action_pressed("Player" + str(input_device) + "Fire") and fire_cd == 0:
		match character_type:
			0:
				fire_cd = 40
				fire(1)
				linear_velocity += Vector2(cos(rotation), sin(rotation)) * -200
			1: 
				fire_cd = 80
				spawn_mine()
				linear_velocity += Vector2(cos(rotation), sin(rotation)) * 100
			2:
				fire_cd = 60
				fire(5)
				linear_velocity += Vector2(cos(rotation), sin(rotation)) * -200
			3:
				fire_cd = 30
				melee_hit()
				linear_velocity += Vector2(cos(rotation), sin(rotation)) * 50
	if fire_cd > 0:
		fire_cd -= 1
	thruster_particles.emitting = Input.is_action_pressed("Player" + str(input_device) + "Move")

func handle_collisions() -> void:
	if get_colliding_bodies()[0] is StaticBody2D:
		collision_sound_emitter.play(0)
		if get_colliding_bodies()[0].get_node("CollisionShape2D").shape is WorldBoundaryShape2D:
			linear_velocity += get_colliding_bodies()[0].get_node("CollisionShape2D").shape.normal * 50
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

func start_dying(body: Node2D = null, damage: int = 1):
	if body is projectile:
		body.you_have_to_kill_yourself = true
	hit_points -= damage
	linear_velocity += (body.position - position).normalized() * -100
	if hit_points > 0:
		hurt_sound_emitter.play()
		angular_velocity += pow(randf_range(-5, 5), 2)
		return
	if death_timer != -1: return
	alarm_sound_emitter.play()
	death_timer = 75
	thruster_particles.emitting = false

func fire(amount: int) -> void:
	if idle_projectile_manager == null: return
	shot_sound_emitter.play()
	var additional_rotation: Array[float]
	additional_rotation.resize(amount)
	for i in range(amount):
		additional_rotation[i] = deg_to_rad(((i - (amount / 2.0 - 0.5)) * 10))
	for i in range(amount):
		var proj := idle_projectile_manager.get_idle_projectile()
		proj.init()
		proj.visible = true
		proj.process_mode = Node.PROCESS_MODE_PAUSABLE
		proj.position = position + (Vector2(cos(rotation), sin(rotation)) * 50)
		proj.velocity = (Vector2(cos(rotation + additional_rotation[i]), sin(rotation + additional_rotation[i])) * randf_range(550, 650)) + linear_velocity

func hide_swing_animation():
	melee_hit_animation.visible = false

func spawn_mine() -> void:
	mine_release_sound_emitter.play()
	var mine := idle_projectile_manager.get_idle_mine()
	mine.init()
	mine.visible = true
	mine.process_mode = Node.PROCESS_MODE_PAUSABLE
	mine.position = position + (Vector2(cos(rotation), sin(rotation)) * -50)
	mine.linear_velocity = (Vector2(cos(rotation), sin(rotation)) * randf_range(-200, -150)) + linear_velocity

func melee_hit() -> void:
	melee_hit_animation.flip_h = not melee_hit_animation.flip_h
	melee_hit_animation.play()
	melee_hit_animation.visible = true
	melee_swing_sound_emitter.play()
	var hit_sound := 0
	var bodies := melee_hit_area.get_overlapping_bodies()
	for body in bodies:
		if body == self: continue
		if body is RigidBody2D:
			hit_sound = 1
			body.linear_velocity += (body.position - position).normalized() * 300
			if body is Player:
				body.start_dying(self, 2)
			elif body is Mine:
				body.linear_velocity += (body.position - position).normalized() * 400
		if body is CharacterBody2D:
			hit_sound = 1
			body.velocity = (body.position - position).normalized() * 600
			if body is projectile:
				hit_sound = 2
		if hit_sound == 1: melee_hit_sound_emitter.play()
		if hit_sound == 2: melee_parry_sound_emitter.play()

func fucking_die(_body: Node2D) -> void:
	death_sound_emitter.play()
	death_particles.emitting = true
	$Sprite2D.visible = false
	call_deferred("set_inactive")
	game_manager.im_dead_lol(self)
