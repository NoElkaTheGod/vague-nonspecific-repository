class_name Player extends RigidBody2D

var hit_points := 0.0
var type_hit_points := [50.0, 40.0, 100.0, 30.0]
var is_player_active := false
var is_input_connected := false
var is_round_going := false
var is_spawning := false
var move_cd := 0
var fire_cd := 0
var stack_fire_cd: Array[int]
var max_move_cd := [5, 6, 8, 3]
var turn_speed := [5, 5, 3, 6]
var death_timer := -1
var alive := false
var angular_velocity_target := 0.0
@onready var sprite_base := $SpriteBase
@onready var sprite_mask := $SpriteBase/SpriteMask
@onready var thrust_sound_emitter := $ThrustSoundEmitter
@onready var thruster_particles := $ThrusterParticles
@onready var death_sound_emitter := $DeathSoundEmitter
@onready var funny_death_sound_emitter := $DeathSoundEmitterFunny
@onready var death_particles := $DeathParticles
@onready var alarm_sound_emitter := $AlarmSoundEmitter
@onready var collision_sound_emitter: CollisionSoundEmitter = $CollisionSoundEmitter
@onready var hurt_sound_emitter := $HurtSoundEmitter
@onready var game_manager: GameManager = get_parent().get_parent()

@onready var healthbar_scene: PackedScene = load("res://scenes/health_bar.tscn")
@onready var cooldownbar_scene: PackedScene = load("res://scenes/cooldown_indicator.tscn")

var bound_indicator_container: VBoxContainer
var bound_player_selector: PlayerSelector
var bound_health_bar: HealthBar
var bound_cooldown_indicators: Array[CooldownIndicator]

var input_device := -1
var character_color: int
const character_colors = [Color.AQUA, Color.ORANGE_RED, Color.BLUE_VIOLET, Color.DARK_ORANGE, Color.YELLOW_GREEN, Color.GOLD]
var character_type: int
var menu_input_cd := [15, 15, 15, 15, 15]

var inventory: Array[Action]
var slot_for_deletion: Action
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
const default_reload_offset = [0, 0, 0, 0]
var cooldown_offset := 0
const default_cooldown_offset = [0, 0, 0, 0]
var recoil_multiplier := 1.0
const default_recoil_multiplier = [1.0, 1.0, 0.8, 1.0]
var projectile_velocity_multiplier := 1.0
const default_projectile_velocity_multiplier = [1.0, 1.0, 1.0, 1.0]

func set_active():
	is_player_active = true
	process_mode = PROCESS_MODE_INHERIT
	sprite_base.visible = true
	$ThrusterParticles.visible = true
	alive = true
	reset_player_state()

func set_inactive():
	is_player_active = false
	process_mode = PROCESS_MODE_DISABLED
	sprite_base.visible = false
	$ThrusterParticles.visible = false
	alive = false

func reset_player_state():
	sprite_base.position = Vector2(3, 0)
	sprite_base.rotation = deg_to_rad(90)
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
	sprite_base.visible = false
	bound_indicator_container = VBoxContainer.new()
	game_manager.get_node("HealthbarContainer").add_child(bound_indicator_container)

func bind_player_selector(node: PlayerSelector, lobby: bool = false) -> void:
	bound_player_selector = node
	node.yo_wassup(self, lobby)

func change_appearence():
	if not game_manager.is_lobby: return
	sprite_base.texture.region = Rect2(0, character_type * 48, 48, 48)
	sprite_mask.texture.region = Rect2(48, character_type * 48, 48, 48)
	sprite_mask.modulate = character_colors[character_color]

func reset_stat_offsets() -> void:
	damage_multiplier = default_damage_multiplier[character_type]
	angle_offset = default_angle_offset[character_type]
	spread_multiplier = default_spread_multiplier[character_type]
	cooldown_offset = default_cooldown_offset[character_type]
	recoil_multiplier = default_recoil_multiplier[character_type]
	projectile_velocity_multiplier = default_projectile_velocity_multiplier[character_type]
	reload_offset = default_reload_offset[character_type]

func change_player_type(type: int):
	if not game_manager.is_lobby: return
	for i in range(inventory.size()):
		if inventory[i] == null: continue
		inventory[i].queue_free()
		inventory[i] = null
	amount_of_stacks = default_amount_of_stacks[type]
	inventory.resize(action_stack_size * (inventory_rows + amount_of_stacks))
	action_stack.resize(amount_of_stacks)
	action_stack_copy.resize(amount_of_stacks)
	stack_fire_cd.resize(amount_of_stacks)
	reset_stat_offsets()
	hit_points = type_hit_points[character_type]
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
	for item in bound_indicator_container.get_children():
		item.free()
	bound_health_bar = healthbar_scene.instantiate()
	bound_indicator_container.add_child(bound_health_bar)
	bound_health_bar.init(type_hit_points[character_type], self)
	bound_cooldown_indicators.resize(amount_of_stacks)
	for i in range(amount_of_stacks):
		bound_cooldown_indicators[i] = cooldownbar_scene.instantiate()
		bound_indicator_container.add_child(bound_cooldown_indicators[i])
		bound_cooldown_indicators[i].init(self)

func init(color: int, device: int) -> void:
	is_input_connected = true
	character_color = color
	input_device = device
	sprite_base.texture = AtlasTexture.new()
	sprite_base.texture.atlas = load("res://sprites/player.png")
	sprite_base.texture.region = Rect2(0, 0, 48, 48)
	sprite_mask.texture = AtlasTexture.new()
	sprite_mask.texture.atlas = load("res://sprites/player.png")
	sprite_mask.texture.region = Rect2(48, 0, 48, 48)
	sprite_mask.modulate = character_colors[character_color]
	change_player_type(0)
	set_active()
	$SpawnSoundEmitter.play()
	game_manager.player_finished_initialisation(self)

func _physics_process(_delta: float) -> void:
	bound_indicator_container.position = position + Vector2(0, -60) - (bound_indicator_container.size / 2)
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
		sprite_base.position = Vector2(randf_range(-10, 10), randf_range(-10, 10))
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
	if Input.is_action_pressed("Player" + str(input_device) + "Fire"):
		if stack_fire_cd[active_stack] <= 0 and fire_cd <= 0:
			fire_action_from_stack(active_stack)
	if fire_cd > 0:
		fire_cd -= 1
	for i in range(stack_fire_cd.size()):
		if stack_fire_cd[i] > 0:
			stack_fire_cd[i] -= 1
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
	sprite_base.visible = false
	set_inactive()
	game_manager.im_dead_lol(self)

func fire_action_from_stack(stack := 0) -> void:
	var action: Action = action_stack_copy[stack].pop_back()
	if action == null:
		fucking_die(self, true)
		return
	if action.item_type == Action.ITEM_TYPE.ACTION:
		bound_cooldown_indicators[stack].action_fired()
	fire_cd = max(action.action(self) + cooldown_offset, fire_cd)
	bound_cooldown_indicators[stack].start_cooldown(fire_cd)
	reload_if_empty_stack(stack)
	if action.trigger_next_immediately:
		fire_action_from_stack(stack)

func get_next_action() -> Action:
	var result: Action = null
	var copy = action_stack_copy[active_stack].duplicate(true)
	while not false: #bro what
		result = copy.pop_back()
		if result.item_type == Action.ITEM_TYPE.ACTION:
			return result
		if action_stack_copy[active_stack].size() == 0:
			return null
	return null

func reload_if_empty_stack(stack) -> void:
	if action_stack_copy[stack].size() > 0: return
	bound_cooldown_indicators[stack].reload_started(reload_time + reload_offset)
	stack_fire_cd[active_stack] = reload_time + reload_offset
	active_stack += 1
	if active_stack >= amount_of_stacks: active_stack = 0
	action_stack_copy[stack] = action_stack[stack].duplicate(true)
	reset_stat_offsets()

func compile_action_stacks() -> void:
	var division_modifier := 0
	var temp := 0
	for stack in range(amount_of_stacks):
		action_stack[stack].clear()
		var amount_of_actions := 0
		for i in range(action_stack_size):
			if inventory[i + (stack * action_stack_size)] == null: continue
			temp = 0
			while division_modifier >= 0:
				if inventory[i + (stack * action_stack_size)].item_type == Action.ITEM_TYPE.ACTION: amount_of_actions += 1
				temp += inventory[i + (stack * action_stack_size)].compile_into_stack(action_stack[stack])
				division_modifier -= 1
			if temp == 0: division_modifier = 0
			else: division_modifier += temp
		bound_cooldown_indicators[stack].set_max_stack_size(amount_of_actions)
		action_stack_copy[stack] = action_stack[stack].duplicate(true)
		if action_stack[stack].size() == 0:
			pass #TODO: "Вы будете мгновенно убиты. Продолжить?"
