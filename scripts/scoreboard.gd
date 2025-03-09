class_name Scoreboard extends Control

@onready var game_manager: GameManager = get_parent().get_parent().get_parent()
@onready var panel: Panel = get_parent().get_node("ScoreboardPanel")
var score_labels: Array[Label]
var player_sprite_bases: Array[TextureRect]
var player_sprite_masks: Array[TextureRect]
var timer := 0

func new_player_joined(player: Player) -> void:
	var new_label = Label.new()
	score_labels.append(new_label)
	add_child(new_label)
	new_label.text = "0"
	var new_player_sprite_base = TextureRect.new()
	player_sprite_bases.append(new_player_sprite_base)
	add_child(new_player_sprite_base)
	new_player_sprite_base.texture = AtlasTexture.new()
	new_player_sprite_base.texture.atlas = load("res://sprites/player.png")
	new_player_sprite_base.texture.region = Rect2(0, player.character_type * 48, 48, 48)
	var new_player_sprite_mask = TextureRect.new()
	player_sprite_masks.append(new_player_sprite_mask)
	new_player_sprite_base.add_child(new_player_sprite_mask)
	new_player_sprite_mask.texture = AtlasTexture.new()
	new_player_sprite_mask.texture.atlas = load("res://sprites/player.png")
	new_player_sprite_mask.texture.region = Rect2(48, player.character_type * 48, 48, 48)
	new_player_sprite_mask.modulate = player.sprite_mask.modulate

func update_player_score() -> void:
	for i in range(game_manager.player_count):
		score_labels[i].text = str(game_manager.player_score[i])
		if game_manager.players[i].input_device == -1: continue
		player_sprite_bases[i].texture.region = Rect2(0, game_manager.players[i].character_type * 48, 48, 48)
		player_sprite_masks[i].texture.region = Rect2(48, game_manager.players[i].character_type * 48, 48, 48)
		player_sprite_masks[i].modulate = game_manager.players[i].sprite_mask.modulate
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
