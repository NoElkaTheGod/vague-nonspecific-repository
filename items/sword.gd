class_name sword_item extends Action


func _ready() -> void:
	texture = "res://sprites/items/sword_item.png"
	item_name = "Меч"
	description = "Это специальный меч для космического корабля. Не спрашивайте. Может парировать снаряды."

func action(_actor: Node2D) -> void:
	pass
