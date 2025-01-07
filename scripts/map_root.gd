class_name MapRoot extends Node2D

var gravity_effectors: Array[Repulsor]
var player_spawners: Array[Vector2]

func _ready() -> void:
	for node in $PlayerSpawners.get_children():
		node = node as Node2D
		player_spawners.append(node.position)
	for node in get_children():
		if node is Repulsor or Attractor: gravity_effectors.append(node as Repulsor)
