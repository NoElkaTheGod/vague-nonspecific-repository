class_name GameManager extends Node

var gravity_effectors: Array[GravityEffector]
var player_spawns: Array[Node2D]
var timer: int = -1
var player_score: Array[int]
var round_is_going := false

var players: Array[Player]
var player_input_devices: Array[bool]
var player_color_numbers := [true, true, true, true]
var player_count := 0
var players_ready := 0
var is_lobby := true

var spawn_timer := -1
var players_to_spawn: Array[Player]
var round_start_countdown := -1

@onready var player_selectors: Control = $PlayerSelectors
@onready var players_container := $PlayersContainer
@onready var idle_projectile_manager: IdleProjectileManager = $IdleProjectileManager
@onready var main_camera: MainCamera = $Camera2D
@onready var scoreboard := $Camera2D/UI/Scoreboard
@onready var map_loader: MapLoader = $MapLoader
@onready var lootbox_manager: LootManager = $LootboxManager
@onready var player_scene: PackedScene = load("res://scenes/player.tscn")
@onready var spawning_fx_scene: PackedScene = load("res://scenes/spawning_crosshair.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action("Restart"):
		end_round()
		return
	if round_is_going: return
	if not event.is_action_type(): return
	if player_count >= 4: return
	var new_player_slot = get_available_player_slot()
	if new_player_slot == -1: return
	if Input.get_connected_joypads().has(event.device) and not player_input_devices[event.device]:
		for i in range(7):
			for j in ["Fire", "Move"]:
				if event.is_action("Player" + str(i) + str(j)) and not player_input_devices[i]:
					player_input_devices[event.device] = true
					players[new_player_slot].init(get_available_color(), event.device)
					return
				return
	for i in [8, 9]:
		for j in ["Fire", "Move", "Left", "Right", "Up", "Down"]:
			if event.is_action("Player" + str(i) + str(j)) and not player_input_devices[i]:
				player_input_devices[i] = true
				players[new_player_slot].init(get_available_color(), i)
				return

func player_finished_initialisation(player: Player) -> void:
	player_count += 1
	player_score.resize(player_count)
	scoreboard.new_player_joined(player)
	move_to_spawn(player)

func set_ready(state: bool) -> void:
	if state: players_ready += 1
	else: players_ready -= 1
	if players_ready == player_count and player_count >= 2:
		map_loader.unload_map()
		players_ready = 0
		start_round()

func get_available_player_slot() -> int:
	for i in range(players.size()):
		if not players[i].is_input_connected:
			return i
	return -1

func get_available_color() -> int:
	for i in range(player_color_numbers.size()):
		if player_color_numbers[i]:
			player_color_numbers[i] = false
			return i
	return 1

func _ready() -> void:
	players.resize(10)
	player_input_devices.resize(10)
	for i in range(10):
		players[i] = player_scene.instantiate()
		players[i].position = main_camera.get_random_spot()
		players_container.add_child(players[i])
	map_loader.load_map(-1)

func account_for_attractors(velocity: Vector2, position: Vector2, coefficient: float) -> Vector2:
	for item in gravity_effectors:
		if item == null:
			gravity_effectors.erase(item)
			continue
		velocity += (item.position - position).normalized() * item.power / item.position.distance_squared_to(position) * coefficient
	return velocity

func im_dead_lol(_player: Player) -> void:
	var alive_players = player_count
	for i in players:
		if not i.alive:
			alive_players -= 1
	if alive_players <= 1:
		main_camera.camera_return_to_center = true
		timer = 60

func _physics_process(_delta: float) -> void:
	if timer != -1:
		if timer > 0: timer -= 1
		else:
			end_round()
	if spawn_timer != -1:
		spawn_timer -= 1
		if spawn_timer == 0:
			spawn_timer = 10
			var player = players_to_spawn.pop_front()
			move_to_spawn(player)
			player.visible = true
			player.reset_player_state()
			var fx = spawning_fx_scene.instantiate()
			fx.init(player)
			add_child(fx)
			if players_to_spawn.size() == 0:
				spawn_timer = -1
				round_start_countdown = 81
	if round_start_countdown != -1:
		round_start_countdown -= 1
		if round_start_countdown == 20:
			main_camera.camera_return_to_center = false
			for i in players:
				if i.input_device == -1: continue
				i.is_round_going = true
				i.is_spawning = false

func start_round() -> void:
	is_lobby = false
	round_is_going = true
	map_loader.load_map(randi_range(0, map_loader.get_map_pool_size() - 1))
	for i in players:
		if i.input_device == -1: continue
		players_to_spawn.append(i)
		i.is_spawning = true
		i.bound_player_selector.round_started()
		i.visible = false
	spawn_timer = 15

func move_to_spawn(player: Player) -> void:
	if player_spawns.size() == 0: return
	var spawn = player_spawns.pick_random()
	player.position = spawn.position
	player_spawns.erase(spawn)
	player.rotation = (player.position - Vector2(960, 640)).rotated(PI).angle()
	if not round_is_going:
		player.bind_player_selector(get_node("PlayerSelectors/Player" + spawn.name), is_lobby)

func end_round() -> void:
	round_is_going = false
	for item in idle_projectile_manager.get_children():
		item.free()
	map_loader.unload_map()
	timer = -1
	map_loader.load_map(-1)
	for i in range(player_count):
		if players[i].alive: player_score[i] += 1
		players[i].set_active()
		players[i].reset_player_state()
		players[i].is_round_going = false
		move_to_spawn(players[i])
	scoreboard.update_player_score()
