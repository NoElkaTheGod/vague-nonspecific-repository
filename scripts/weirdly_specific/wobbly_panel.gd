class_name WobblyPanel extends Panel

var wobbliness := 1.0
var counter := 0.0

func _process(delta: float) -> void:
	counter += fmod(delta * 12, PI)
	rotation = sin(counter * wobbliness) / 12.0

func _ready() -> void:
	pivot_offset = size / 2
