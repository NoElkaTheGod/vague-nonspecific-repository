class_name Player extends RigidBody2D

var hit_points := 0.0
var type_hit_points := [50.0, 40.0, 100.0, 10.0]
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
@onready var death_sound_emitter := $DeathSoundEmitter
@onready var funny_death_sound_emitter := $DeathSoundEmitterFunny
@onready var death_particles := $DeathParticles
@onready var alarm_sound_emitter := $AlarmSoundEmitter
@onready var collision_sound_emitter: CollisionSoundEmitter = $CollisionSoundEmitter
@onready var hurt_sound_emitter := $HurtSoundEmitter
@onready var idle_projectile_manager: IdleProjectileManager = get_parent().get_parent().get_node("IdleProjectileManager")
@onready var game_manager: GameManager = get_parent().get_parent()
var bound_player_selector: PlayerSelector
var bound_health_bar: HealthBar
var input_device := -1
var character_color: int
var character_type: int
var menu_input_cd := [15, 15, 15, 15, 15]

var inventory: Array[Action]
var action_stack_size := 8
var inventory_rows := 2
var amount_of_stacks := 1
var default_amount_of_stacks := [1, 1, 2, 1]

var action_stack: Array[Array]
var action_stack_copy: Array[Array]
var active_stack := 0
var reset_pause := 0
const reload_time := 40

var damage_multiplier := 1.0
const default_damage_multiplier = [1.0, 2.0, 1.0, 1.0]
var angle_offset := 0
const default_angle_offset = [0, PI, 0, 0]
var spread_multiplier := 1.0
const default_spread_multiplier = [1.0, 1.0, 4.0, 1.0]
var reload_offset := 0
const default_reload_offset = [0, 0, -20, 0]
var cooldown_multiplier := 1.0
const default_cooldown_multiplier = [1.0, 1.0, 0.5, 1.0]
var recoil_multiplier := 1.0
const default_recoil_multiplier = [1.0, 1.0, 0.8, 1.0]
var projectile_velocity_multiplier := 1.0
const default_projectile_velocity_multiplier = [1.0, 1.0, 1.0, 1.0]

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
	fire_cd = 0
	for i in range(5):
		if menu_input_cd[i] > 0:
			menu_input_cd[i] -= 1
	hit_points = type_hit_points[character_type]
	bound_health_bar.init(type_hit_points[character_type], self)

func _ready() -> void:
	$ThrusterParticles.visible = false
	sprite.visible = false
	bound_health_bar = load("res://scenes/health_bar.tscn").instantiate()
	game_manager.get_node("HealthbarsContainer").add_child(bound_health_bar)
	bound_health_bar.init(type_hit_points[character_type], self)

func bind_player_selector(node: PlayerSelector, lobby: bool = false) -> void:
	bound_player_selector = node
	node.yo_wassup(self, lobby)

func change_appearence():
	$Sprite2D.texture.region = Rect2(character_color * 48, character_type * 48, 48, 48)

func reset_stat_offsets() -> void:
	damage_multiplier = default_damage_multiplier[character_type]
	angle_offset = default_angle_offset[character_type]
	spread_multiplier = default_spread_multiplier[character_type]
	cooldown_multiplier = default_cooldown_multiplier[character_type]
	recoil_multiplier = default_recoil_multiplier[character_type]
	projectile_velocity_multiplier = default_projectile_velocity_multiplier[character_type]

func reset_reload_offset() -> void:
	reload_offset = default_reload_offset[character_type]

func change_player_type(type: int):
	for i in range(inventory.size()):
		if inventory[i] == null: continue
		inventory[i].queue_free()
		inventory[i] = null
	amount_of_stacks = default_amount_of_stacks[type]
	inventory.resize(action_stack_size * (inventory_rows + amount_of_stacks))
	action_stack.resize(amount_of_stacks)
	action_stack_copy.resize(amount_of_stacks)
	reset_stat_offsets()
	bound_health_bar.init(type_hit_points[type], self)
	match type:
		0:
			inventory[0] = shot_item.new()
			add_child(inventory[0])
		1:
			inventory[0] = mine_item.new()
			add_child(inventory[0])
		2:
			inventory[0] = shot_item.new()
			inventory[action_stack_size] = shot_item.new()
			add_child(inventory[0])
			add_child(inventory[action_stack_size])
		3:
			inventory[0] = missile_item.new()
			add_child(inventory[0])

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
	change_player_type(0)

func _physics_process(_delta: float) -> void:
	if is_spawning: return
	if not is_round_going:
		linear_velocity = Vector2.ZERO
		angular_velocity = PI
		for i in range(5):
			if menu_input_cd[i] > 0:
				menu_input_cd[i] -= 1
		if bound_player_selector == null: return
		if Input.is_action_pressed("Player" + str(input_device) + "Fire"):
			if menu_input_cd[0] == 0:
				bound_player_selector.fire_pressed()
				menu_input_cd[0] = 15
			return
		if Input.is_action_just_released("Player" + str(input_device) + "Fire"):
				menu_input_cd[0] = 0
		if input_device <= 7:
			if Input.get_joy_axis(input_device,JOY_AXIS_LEFT_X) < -0.5:
				if menu_input_cd[1] == 0:
					bound_player_selector.left_pressed()
					menu_input_cd[1] = 15
			if Input.get_joy_axis(input_device,JOY_AXIS_LEFT_X) > 0.5:
				if menu_input_cd[2] == 0:
					bound_player_selector.right_pressed()
					menu_input_cd[2] = 15
			if Input.get_joy_axis(input_device,JOY_AXIS_LEFT_Y) > 0.5:
				if menu_input_cd[3] == 0:
					bound_player_selector.down_pressed()
					menu_input_cd[3] = 15
			if Input.get_joy_axis(input_device,JOY_AXIS_LEFT_Y) < -0.5:
				if menu_input_cd[4] == 0:
					bound_player_selector.up_pressed()
					menu_input_cd[4] = 15
		if Input.is_action_pressed("Player" + str(input_device) + "Left"):
			if menu_input_cd[1] == 0:
				bound_player_selector.left_pressed()
				menu_input_cd[1] = 15
		if Input.is_action_pressed("Player" + str(input_device) + "Right"):
			if menu_input_cd[2] == 0:
				bound_player_selector.right_pressed()
				menu_input_cd[2] = 15
		if Input.is_action_pressed("Player" + str(input_device) + "Up"):
			if menu_input_cd[3] == 0:
				bound_player_selector.up_pressed()
				menu_input_cd[3] = 15
		if Input.is_action_pressed("Player" + str(input_device) + "Down"):
			if menu_input_cd[4] == 0:
				bound_player_selector.down_pressed()
				menu_input_cd[4] = 15
		if Input.is_action_just_released("Player" + str(input_device) + "Left"):
			menu_input_cd[1] = 0
		if Input.is_action_just_released("Player" + str(input_device) + "Right"):
			menu_input_cd[2] = 0
		if Input.is_action_just_released("Player" + str(input_device) + "Up"):
			menu_input_cd[3] = 0
		if Input.is_action_just_released("Player" + str(input_device) + "Down"):
			menu_input_cd[4] = 0
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
		active_stack += 1
		if active_stack >= amount_of_stacks: active_stack = 0
		fire_action_from_stack(active_stack)
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
			angular_velocity += pow(randf_range(-7, 7), 2)
		elif (achtung.linear_velocity + linear_velocity).length() < 1500.0 and (achtung.linear_velocity.length() + linear_velocity.length()) > 500.0:
			collision_sound_emitter.play(2)
			angular_velocity += pow(randf_range(-5, 5), 2)
		else:
			collision_sound_emitter.play(1)
			angular_velocity += pow(randf_range(-3, 3), 2)

func take_damage(body: Node2D = null, damage: int = 1):
	bound_health_bar.damage_taken(damage)
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

func fucking_die(_body: Node2D, funny_sound := false) -> void:
	if funny_sound:
		funny_death_sound_emitter.play()
	else:
		death_sound_emitter.play()
	death_particles.emitting = true
	$Sprite2D.visible = false
	set_inactive()
	game_manager.im_dead_lol(self)

func fire_action_from_stack(stack := 0) -> void:
	var action: Action = action_stack_copy[stack].pop_back()
	if action == null:
		fucking_die(self, true)
		return
	fire_cd = max(action.action(self) * cooldown_multiplier, fire_cd)
	reload_if_empty_stack(stack)
	if action.item_type != Action.ITEM_TYPE.MODIFIER and reset_pause == 0:
		reset_stat_offsets()
	if reset_pause > 0: reset_pause -= 1
	if action.trigger_next_immediately:
		fire_action_from_stack(stack)

func get_next_action() -> Action:
	var result: Action = null
	var i = 0
	while not false: #bro what
		i -= 1
		if i == -1: fucking_die(self, true)
		if action_stack_copy[active_stack][i].item_type == Action.ITEM_TYPE.ACTION:
			result = action_stack_copy[active_stack][i]
			break
		if action_stack_copy[active_stack].size() == 0: return null
	return result

func reload_if_empty_stack(stack) -> void:
	if action_stack_copy[stack].size() == 0:
		action_stack_copy[stack] = action_stack[stack].duplicate(true)
		fire_cd = max(reload_time + reload_offset, fire_cd)
		reset_reload_offset()

func compile_action_stacks() -> void:
	var division_modifier := 0
	var temp := 0
	for stack in range(amount_of_stacks):
		action_stack[stack].clear()
		for i in range(action_stack_size):
			if inventory[i + (stack * action_stack_size)] == null: continue
			temp = 0
			while division_modifier >= 0:
				temp += inventory[i + (stack * action_stack_size)].compile_into_stack(action_stack[stack])
				division_modifier -= 1
			if temp == 0: division_modifier = 0
			else: division_modifier += temp
		action_stack_copy[stack] = action_stack[stack].duplicate(true)
		if action_stack[stack].size() == 0:
			pass #TODO: "Вы будете мгновенно убиты. Продолжить?"
