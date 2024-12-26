class_name GameManager extends Node

var players: Array[Player]
var attractors: Array[Attractor]
var repulsors: Array[Repulsor]
var player_amount: int = 2
var attractor_pairs: int = 3

var idle_projectile_manager: IdleProjectileManager
@onready var main_camera: MainCamera = $Camera2D
@onready var player_scene: PackedScene = load("res://scenes/player.tscn")
@onready var attractor_scene: PackedScene = load("res://scenes/attractor.tscn")
@onready var repulsor_scene: PackedScene = load("res://scenes/repulsor.tscn")

func _ready() -> void:
	start_round()

func _input(event: InputEvent) -> void:
	if event.is_action("Restart round") and event.is_released():
		end_round()

func account_for_attractors(velocity: Vector2, position: Vector2, coefficient: int) -> Vector2:
	for item in attractors:
		velocity += (item.position - position).normalized() * item.power / item.position.distance_squared_to(position) * coefficient
	for item in repulsors:
		velocity += (item.position - position).normalized() * item.power / item.position.distance_squared_to(position) * coefficient
	return velocity


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
	attractors.resize(attractor_pairs)
	repulsors.resize(attractor_pairs)
	for i in range(attractor_pairs):
		attractors[i] = attractor_scene.instantiate()
		repulsors[i] = repulsor_scene.instantiate()
		add_child(attractors[i])
		add_child(repulsors[i])
		attractors[i].init(120000, repulsors[i])
		repulsors[i].init(-120000, attractors[i])
		attractors[i].position = main_camera.get_random_spot()
		repulsors[i].position = main_camera.get_random_spot()

func end_round() -> void:
	for item in idle_projectile_manager.get_children():
		item.free()
	idle_projectile_manager.free()
	for item in players:
		item.queue_free()
	for item in attractors:
		item.queue_free()
	for item in repulsors:
		item.queue_free()
	start_round()
