class_name Scoreboard extends Control

@onready var game_manager: GameManager = get_parent()
@onready var player_icons := $TextureRect
var score_labels: Array[Label]
var timer: int

func _ready() -> void:
	player_icons.texture.region.size.x = game_manager.player_amount * 48
	score_labels.resize(game_manager.player_amount)
	for i in range(game_manager.player_amount):
		score_labels[i] = Label.new()
		add_child(score_labels[i])
		score_labels[i].position = Vector2(i * 48 + 20, 50)

func update_player_score() -> void:
	for i in range(game_manager.player_amount):
		score_labels[i].text = str(game_manager.player_score[i])
	modulate = Color(1, 1, 1, 1)
	timer = 120

func _physics_process(_delta: float) -> void:
	if timer > 0: timer -= 1
	if timer < 60: modulate = Color(1, 1, 1, timer / 60.0)
