class_name MapLoader extends Node

@onready var game_manager: GameManager = get_parent()
var map_pool: Array[PackedScene]
var loaded_map

func get_map_pool_size() -> int:
	return map_pool.size()

func _ready() -> void:
	var map_scene_names = DirAccess.get_files_at("res://scenes/maps/")
	for scene in map_scene_names:
		map_pool.append(load("res://scenes/maps/" + scene))

func unload_map() -> void:
	for item in get_children():
		item.queue_free()
	game_manager.gravity_effectors.clear()

func load_map(map: int) -> void:
	map = clamp(map, 0, map_pool.size())
	loaded_map = map_pool[map].instantiate()
	add_child(loaded_map)
	if loaded_map is not MapRoot: return
	var map_root := loaded_map as MapRoot
	game_manager.gravity_effectors = map_root.gravity_effectors
	game_manager.player_spawns = map_root.player_spawners
	#attractors.resize(attractor_amount)
	#for i in range(attractor_amount):
	#	attractors[i] = attractor_scene.instantiate()
	#	add_child(attractors[i])
	#	attractors[i].init(120000)
	#	attractors[i].position = main_camera.get_random_spot()
	#repulsors.resize(repulsor_amount)
	#for i in range(repulsor_amount):
	#	repulsors[i] = repulsor_scene.instantiate()
	#	add_child(repulsors[i])
	#	repulsors[i].init(-120000)
	#	repulsors[i].position = main_camera.get_random_spot()
	#rocks.resize(rock_amount)
	#for i in range(rock_amount):
	#	rocks[i] = rock_scene.instantiate()
	#	add_child(rocks[i])
	#	rocks[i].position = main_camera.get_random_spot()
	#	rocks[i].linear_velocity = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) * randf_range(50, 100)
	#wormholes.resize(wormhole_pairs * 2)
	#for i in range(wormhole_pairs):
	#	wormholes[i * 2] = wormhole_scene.instantiate()
	#	wormholes[i * 2 + 1] = wormhole_scene.instantiate()
	#	add_child(wormholes[i * 2])
	#	add_child(wormholes[i * 2 + 1])
	#	wormholes[i * 2].linked_wormhole = wormholes[i * 2 + 1]
	#	wormholes[i * 2 + 1].linked_wormhole = wormholes[i * 2]
	#	wormholes[i * 2].modulate = Color(randf(), randf(), randf())
	#	wormholes[i * 2 + 1].modulate = wormholes[i * 2].modulate
	#	wormholes[i * 2].position = main_camera.get_random_spot()
	#	wormholes[i * 2 + 1].position = main_camera.get_random_spot()
