class_name UI extends Control

func _ready() -> void:
	get_viewport().connect("size_changed", viewport_size_changed)

func viewport_size_changed() -> void:
	size = get_viewport_rect().size
