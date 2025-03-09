extends Sprite2D

func _ready() -> void:
	texture.region.position.x = randi_range(0, 1) * 112
	texture.region.position.y = randi_range(0, 1) * 80
