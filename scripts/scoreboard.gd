class_name Scoreboard extends Control

@onready var game_manager: GameManager = get_parent().get_parent().get_parent()
@onready var panel: Panel = get_parent().get_node("ScoreboardPanel")
var score_labels: Array[Label]
var player_sprites: Array[TextureRect]
var timer := 0

func new_player_joined(player: Player) -> void:
	var new_label = Label.new()
	score_labels.append(new_label)
	add_child(new_label)
	new_label.text = "0"
	var new_player_sprite = TextureRect.new()
	player_sprites.append(new_player_sprite)
	add_child(new_player_sprite)
	new_player_sprite.texture = AtlasTexture.new()
	new_player_sprite.texture.atlas = load("res://sprites/player.png")
	new_player_sprite.texture.region = Rect2(player.character_color * 48, player.character_type * 48, 48, 48)

func update_player_score() -> void:
	for i in range(game_manager.player_count):
		score_labels[i].text = str(game_manager.player_score[i])
		if game_manager.players[i].input_device == -1: continue
		player_sprites[i].texture.region = Rect2(game_manager.players[i].character_color * 48, game_manager.players[i].character_type * 48, 48, 48)
	panel.modulate = Color(1, 1, 1, 1)
	modulate = Color(1, 1, 1, 1)
	timer = 180

func _physics_process(_delta: float) -> void:
	panel.size = size
	panel.position = position
	if timer == -1: return
	if timer > 0: timer -= 1
	if timer < 60:
		panel.modulate = Color(1, 1, 1, timer / 60.0)
		modulate = Color(1, 1, 1, timer / 60.0)
