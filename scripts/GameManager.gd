class_name GameManager extends Node

var gravity_effectors: Array[Repulsor]
var player_spawns: Array[Vector2]
var powerups: Array[Powerup]
var powerup_spawn_cd: int = 500
var timer: int
var timer_2: int = -1
var player_score: Array[int]
var round_is_going := false

var players: Array[Player]
var player_input_devices: Array[bool]
var player_color_numbers := [true, true, true, true]
var player_count := 0

@onready var players_container := $PlayersContainer
@onready var idle_projectile_manager: IdleProjectileManager = $IdleProjectileManager
@onready var main_camera: MainCamera = $Camera2D
@onready var scoreboard := $Camera2D/UI/Scoreboard
@onready var map_loader: MapLoader = $MapLoader
@onready var player_scene: PackedScene = load("res://scenes/player.tscn")
@onready var powerup_scene: PackedScene = load("res://scenes/powerup.tscn")

func _input(event: InputEvent) -> void:
	if round_is_going: return
	if not event.is_action_type(): return
	if player_count >= 4: return
	var new_player_slot = get_available_player_slot()
	if new_player_slot == -1: return
	if Input.get_connected_joypads().has(event.device) and not player_input_devices[event.device]:
		player_input_devices[event.device] = true
		players[new_player_slot].init(get_available_color(), event.device)
		return
	for i in [8, 9]:
		for j in ["Fire", "Move", "Left", "Right"]:
			if event.is_action("Player" + str(i) + str(j)) and not player_input_devices[i]:
				player_input_devices[i] = true
				players[new_player_slot].init(get_available_color(), i)
				return

func player_finished_initialisation() -> void:
	player_count += 1
	player_score.resize(player_count)
	scoreboard.new_player_joined(player_count)

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
		timer_2 = 60

func _physics_process(_delta: float) -> void:
	if timer_2 == -1: return
	if timer_2 > 0: timer_2 -= 1
	else:
		end_round()
	if not round_is_going: return
	if timer < powerup_spawn_cd:
		timer += 1
	else:
		timer = 0
		var new_powerup = powerup_scene.instantiate()
		new_powerup.init(randi_range(0, 2), main_camera.get_random_spot_offscreen(1), main_camera.get_random_spot_offscreen(0))
		powerups.append(new_powerup)
		map_loader.add_child(new_powerup)

func start_round() -> void:
	main_camera.camera_return_to_center = false
	round_is_going = true
	map_loader.load_map(randi_range(0, map_loader.get_map_pool_size() - 1))
	for i in players:
		if i.input_device == -1: continue
		i.set_active()
		i.reset_player_state()
		i.position = player_spawns.pick_random()
		player_spawns.erase(i.position)
		i.rotation = 0

func end_round() -> void:
	round_is_going = false
	for i in range(player_count):
		if players[i].alive: player_score[i] += 1
	scoreboard.update_player_score()
	for item in idle_projectile_manager.get_children():
		item.free()
	for item in powerups:
		item.queue_free()
		item = null
	map_loader.unload_map()
	powerups.resize(0)
	timer = 0
	timer_2 = -1
	start_round()
