class_name GameManager extends Node

var players: Array[Player]
var attractors: Array[Attractor]
var repulsors: Array[Repulsor]
var wormholes: Array[Wormhole]
var rocks: Array[Rock]
var powerups: Array[Powerup]
var player_amount: int = 3
var attractor_amount: int = 2
var repulsor_amount: int = 2
var wormhole_pairs: int = 2
var rock_amount: int = 3
var powerup_spawn_cd: int = 600
var timer: int
var timer_2: int = -1
var player_score: Array[int]

var idle_projectile_manager: IdleProjectileManager
@onready var main_camera: MainCamera = $Camera2D
@onready var scoreboard := $Scoreboard
@onready var player_scene: PackedScene = load("res://scenes/player.tscn")
@onready var attractor_scene: PackedScene = load("res://scenes/attractor.tscn")
@onready var repulsor_scene: PackedScene = load("res://scenes/repulsor.tscn")
@onready var wormhole_scene: PackedScene = load("res://scenes/wormhole.tscn")
@onready var rock_scene: PackedScene = load("res://scenes/rock.tscn")
@onready var powerup_scene: PackedScene = load("res://scenes/powerup.tscn")

func _ready() -> void:
	player_score.resize(player_amount)
	for i in range(player_amount):
		player_score[i] = 0
	start_round()
	scoreboard.update_player_score()

func account_for_attractors(velocity: Vector2, position: Vector2, coefficient: float) -> Vector2:
	for item in attractors:
		velocity += (item.position - position).normalized() * item.power / item.position.distance_squared_to(position) * coefficient
	for item in repulsors:
		velocity += (item.position - position).normalized() * item.power / item.position.distance_squared_to(position) * coefficient
	return velocity

func im_dead_lol(player: Player) -> void:
	players.erase(player)
	if players.size() <= 1:
		timer_2 = 60

func _physics_process(_delta: float) -> void:
	if timer < powerup_spawn_cd:
		timer += 1
	else:
		timer = 0
		var new_powerup = powerup_scene.instantiate()
		new_powerup.init(randi_range(0, 2), main_camera.get_random_spot_offscreen(1), main_camera.get_random_spot_offscreen(0))
		powerups.append(new_powerup)
		add_child(new_powerup)
	if timer_2 == -1: return
	if timer_2 > 0: timer_2 -= 1
	else:
		end_round()
		timer_2 = -1

func start_round() -> void:
	idle_projectile_manager = IdleProjectileManager.new()
	add_child(idle_projectile_manager)
	idle_projectile_manager.name = "IdleProjectileManager"
	players.resize(player_amount)
	for i in range(player_amount):
		players[i] = player_scene.instantiate()
		players[i].init(i)
		players[i].position = main_camera.get_arena_corner(i)
		players[i].rotation = main_camera.get_arena_corner_direction(i)
		add_child(players[i])
	attractors.resize(attractor_amount)
	for i in range(attractor_amount):
		attractors[i] = attractor_scene.instantiate()
		add_child(attractors[i])
		attractors[i].init(120000)
		attractors[i].position = main_camera.get_random_spot()
	repulsors.resize(repulsor_amount)
	for i in range(repulsor_amount):
		repulsors[i] = repulsor_scene.instantiate()
		add_child(repulsors[i])
		repulsors[i].init(-120000)
		repulsors[i].position = main_camera.get_random_spot()
	rocks.resize(rock_amount)
	for i in range(rock_amount):
		rocks[i] = rock_scene.instantiate()
		add_child(rocks[i])
		rocks[i].position = main_camera.get_random_spot()
		rocks[i].linear_velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * randf_range(50, 100)
	wormholes.resize(wormhole_pairs * 2)
	for i in range(wormhole_pairs):
		wormholes[i * 2] = wormhole_scene.instantiate()
		wormholes[i * 2 + 1] = wormhole_scene.instantiate()
		add_child(wormholes[i * 2])
		add_child(wormholes[i * 2 + 1])
		wormholes[i * 2].linked_wormhole = wormholes[i * 2 + 1]
		wormholes[i * 2 + 1].linked_wormhole = wormholes[i * 2]
		wormholes[i * 2].modulate = Color(randf(), randf(), randf())
		wormholes[i * 2 + 1].modulate = wormholes[i * 2].modulate
		wormholes[i * 2].position = main_camera.get_random_spot()
		wormholes[i * 2 + 1].position = main_camera.get_random_spot()

func end_round() -> void:
	if players[0] != null:
		player_score[players[0].player] += 1
	scoreboard.update_player_score()
	for item in idle_projectile_manager.get_children():
		item.free()
	idle_projectile_manager.free()
	for item in players:
		item.queue_free()
	for item in attractors:
		item.queue_free()
	for item in repulsors:
		item.queue_free()
	for item in wormholes:
		item.queue_free()
	for item in rocks:
		item.queue_free()
	for item in powerups:
		item.queue_free()
		item = null
	powerups.resize(0)
	timer = 0
	start_round()
