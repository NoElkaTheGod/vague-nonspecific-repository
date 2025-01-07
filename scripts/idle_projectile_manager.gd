class_name IdleProjectileManager extends Node

var idle_projectiles: Array[projectile]
@onready var projectile_scene: PackedScene = load("res://scenes/projectile.tscn")
@onready var projectile_remainder_scene: PackedScene = load("res://scenes/bullet_remainder.tscn")

func _ready() -> void:
	idle_projectiles.resize(10)
	for i in range(10):
		idle_projectiles[i] = projectile_scene.instantiate()
		add_child(idle_projectiles[i])
		idle_projectiles[i].idle_projectile_manager = self
		idle_projectiles[i].process_mode = Node.PROCESS_MODE_DISABLED
		idle_projectiles[i].visible = false

func add_idle_projectile(item:projectile) -> void:
	idle_projectiles.append(item)
	item.visible = false
	item.process_mode = Node.PROCESS_MODE_DISABLED
	item.get_child(0).restart()

func get_idle_projectile() -> projectile:
	var result = idle_projectiles.pop_back()
	if result != null:
		return result
	result = projectile_scene.instantiate()
	add_child(result)
	result.idle_projectile_manager = self
	return result

func spawn_bullet_remainder(position: Vector2):
	var spawn = projectile_remainder_scene.instantiate()
	add_child(spawn)
	spawn.position = position
