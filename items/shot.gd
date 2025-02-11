class_name shot_item extends Action


func _ready() -> void:
	texture = "res://sprites/items/shot_item.png"
	item_name = "Снаряд"
	description = "Самый обычный снаряд."

func action(_actor: Node2D) -> void:
	pass
