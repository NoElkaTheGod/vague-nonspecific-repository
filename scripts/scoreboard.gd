class_name Scoreboard extends Control

@onready var game_manager: GameManager = get_parent().get_parent().get_parent()
@onready var player_icons := $TextureRect
var score_labels: Array[Label]
var timer: int

func new_player_joined(number: int) -> void:
	var new_label = Label.new()
	score_labels.append(new_label)
	add_child(new_label)
	new_label.position = Vector2(number * 48 + 20, 50)

func update_player_score() -> void:
	for i in range(game_manager.player_count):
		score_labels[i].text = str(game_manager.player_score[i])
	modulate = Color(1, 1, 1, 1)
	timer = 120

func _physics_process(_delta: float) -> void:
	if timer > 0: timer -= 1
	if timer < 60: modulate = Color(1, 1, 1, timer / 60.0)
