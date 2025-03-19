class_name MapLoader extends Node

@onready var game_manager: GameManager = get_parent()
var map_pool: Array[PackedScene]
var lobby_map: PackedScene
var loaded_map

func get_map_pool_size() -> int:
	return map_pool.size()

func _ready() -> void:
	var map_scene_names = DirAccess.get_files_at("res://scenes/maps/")
	for scene in map_scene_names:
		if scene.ends_with(".remap"): continue
		map_pool.append(load("res://scenes/maps/" + scene))
	lobby_map = load("res://scenes/map_lobby.tscn")

func unload_map() -> void:
	for item in get_children():
		item.queue_free()
	game_manager.gravity_effectors.clear()

func load_map(map: int) -> void:
	if map == -1:
		loaded_map = lobby_map.instantiate()
	else:
		map = clamp(map, 0, map_pool.size())
		loaded_map = map_pool[map].instantiate()
	add_child(loaded_map)
	if loaded_map is not MapRoot: return
	var map_root := loaded_map as MapRoot
	game_manager.gravity_effectors = map_root.gravity_effectors
	game_manager.player_spawns = map_root.player_spawners
