class_name BaseComponent extends Node

var actor: Node2D

func terminate() -> void:
	queue_free()
