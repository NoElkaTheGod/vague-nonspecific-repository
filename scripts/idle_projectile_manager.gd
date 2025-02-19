class_name IdleProjectileManager extends Node

var idle_projectiles: Array[projectile]
var idle_mines: Array[Mine]
var idle_missiles: Array[Missile]
@onready var projectile_scene: PackedScene = load("res://scenes/projectile.tscn")
@onready var missile_scene: PackedScene = load("res://scenes/missile.tscn")
@onready var mine_scene: PackedScene = load("res://scenes/mine.tscn")
@onready var projectile_remainder_scene: PackedScene = load("res://scenes/bullet_remainder.tscn")
@onready var missile_remainder_scene: PackedScene = load("res://scenes/missile_remainder.tscn")
@onready var mine_remainder_scene: PackedScene = load("res://scenes/mine_remainder.tscn")

func _ready() -> void:
	idle_projectiles.resize(10)
	for i in range(10):
		idle_projectiles[i] = projectile_scene.instantiate()
		add_child(idle_projectiles[i])
		idle_projectiles[i].idle_projectile_manager = self
		idle_projectiles[i].process_mode = Node.PROCESS_MODE_DISABLED
		idle_projectiles[i].visible = false

func add_idle_projectile(item: projectile) -> void:
	idle_projectiles.append(item)
	item.visible = false
	item.process_mode = Node.PROCESS_MODE_DISABLED
	item.get_node("GPUParticles2D").restart()

func get_idle_projectile() -> projectile:
	var result = idle_projectiles.pop_back()
	if result != null:
		return result
	result = projectile_scene.instantiate()
	add_child(result)
	result.idle_projectile_manager = self
	return result

func add_idle_missile(item: Missile) -> void:
	idle_missiles.append(item)
	item.visible = false
	item.process_mode = Node.PROCESS_MODE_DISABLED
	item.get_node("GPUParticles2D").restart()

func get_idle_missile() -> Missile:
	var result = idle_missiles.pop_back()
	if result != null:
		return result
	result = missile_scene.instantiate()
	add_child(result)
	result.idle_projectile_manager = self
	return result

func add_idle_mine(item: Mine) -> void:
	idle_mines.append(item)
	item.visible = false
	item.process_mode = Node.PROCESS_MODE_DISABLED
	#item.get_node("GPUParticles2D").restart()

func get_idle_mine() -> Mine:
	var result = idle_mines.pop_back()
	if result != null:
		return result
	result = mine_scene.instantiate()
	add_child(result)
	result.idle_projectile_manager = self
	return result

func spawn_bullet_remainder(position: Vector2):
	var spawn = projectile_remainder_scene.instantiate()
	add_child(spawn)
	spawn.position = position 

func spawn_missile_remainder(position: Vector2):
	var spawn = missile_remainder_scene.instantiate()
	add_child(spawn)
	spawn.position = position 

func spawn_mine_remainder(position: Vector2):
	var spawn = mine_remainder_scene.instantiate()
	add_child(spawn)
	spawn.position = position
