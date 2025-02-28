class_name MapRoot extends Node2D

var gravity_effectors: Array[GravityEffector]
var player_spawners: Array[Node2D]

func _ready() -> void:
	for node in $PlayerSpawners.get_children():
		player_spawners.append(node as Node2D)
	for node in get_children():
		if node is GravityEffector: gravity_effectors.append(node)
