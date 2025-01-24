class_name PlayerSelector extends Control

var bound_player: Player
var color: int
var type: int = 0
var timer := 0
var player_ready := false
var text_to_print: String
var printing_progress: int = -1
var is_in_lobby := true

@export var character_type_descriptions: Array[String]

@onready var label_of_readiness := $Ready
@onready var player_sprite := $LobbyButtons/Player
@onready var buttons := $LobbyButtons
@onready var other_buttons := $NotLobbyButtons
@onready var button_up := $LobbyButtons/Up
@onready var button_down := $LobbyButtons/Down
@onready var button_left := $LobbyButtons/Left
@onready var button_right := $LobbyButtons/Right
@onready var stat_panel := $Stats
@onready var sound := $PressDoundEmitter

func _ready() -> void:
	button_up.texture = AtlasTexture.new()
	button_down.texture = AtlasTexture.new()
	button_left.texture = AtlasTexture.new()
	button_right.texture = AtlasTexture.new()
	button_up.texture.atlas = load("res://sprites/buppon.png")
	button_down.texture.atlas = load("res://sprites/buppon.png")
	button_left.texture.atlas = load("res://sprites/buppon.png")
	button_right.texture.atlas = load("res://sprites/buppon.png")
	button_up.texture.region = Rect2(96, 0, 32, 32)
	button_down.texture.region = Rect2(64, 0, 32, 32)
	button_left.texture.region = Rect2(0, 0, 32, 32)
	button_right.texture.region = Rect2(32, 0, 32, 32)
	
func yo_wassup(player: Player, is_lobby: bool = true) -> void:
	bound_player = player
	visible = true
	player_ready = false
	label_of_readiness.self_modulate = Color(0.5, 0, 0)
	label_of_readiness.text = "Not ready"
	player_sprite.texture = AtlasTexture.new()
	player_sprite.texture.atlas = load("res://sprites/player.png")
	player_sprite.texture.region = Rect2(bound_player.character_color * 48, bound_player.character_type * 48, 48, 48)
	update_stat_text(bound_player.character_type)
	is_in_lobby = is_lobby
	if position.x > 1000:
		label_of_readiness.size_flags_horizontal = SIZE_SHRINK_END
		buttons.size_flags_horizontal = SIZE_SHRINK_END
		other_buttons.size_flags_horizontal = SIZE_SHRINK_END
	else:
		label_of_readiness.size_flags_horizontal = SIZE_SHRINK_BEGIN
		buttons.size_flags_horizontal = SIZE_SHRINK_BEGIN
		other_buttons.size_flags_horizontal = SIZE_SHRINK_BEGIN
	if is_lobby:
		buttons.visible = true
		other_buttons.visible = false
	else:
		buttons.visible = false
		other_buttons.visible = true

func round_started() -> void:
	bound_player.bound_player_selector = null
	bound_player = null
	visible = false

func left_pressed():
	sound.play()
	if is_in_lobby:
		timer = 6
		button_left.texture.region.position.y = 32
		var prev_color = bound_player.character_color
		for i in range(4):
			bound_player.character_color += 1
			if bound_player.character_color > 3: bound_player.character_color = 0
			if bound_player.game_manager.player_color_numbers[bound_player.character_color]:
				bound_player.game_manager.player_color_numbers[prev_color] = true
				break
		bound_player.game_manager.player_color_numbers[bound_player.character_color] = false
		bound_player.change_appearence()
		player_sprite.texture.region = Rect2(bound_player.character_color * 48, bound_player.character_type * 48, 48, 48)

func right_pressed():
	sound.play()
	if is_in_lobby:
		timer = 6
		button_right.texture.region.position.y = 32
		var prev_color = bound_player.character_color
		for i in range(4):
			bound_player.character_color -= 1
			if bound_player.character_color < 0: bound_player.character_color = 3
			if bound_player.game_manager.player_color_numbers[bound_player.character_color]:
				bound_player.game_manager.player_color_numbers[prev_color] = true
				break
		bound_player.game_manager.player_color_numbers[bound_player.character_color] = false
		bound_player.change_appearence()
		player_sprite.texture.region = Rect2(bound_player.character_color * 48, bound_player.character_type * 48, 48, 48)

func up_pressed():
	sound.play()
	if is_in_lobby:
		timer = 6
		button_up.texture.region.position.y = 32
		bound_player.character_type += 1
		if bound_player.character_type > 3: bound_player.character_type = 0
		update_stat_text(bound_player.character_type)
		bound_player.change_appearence()
		player_sprite.texture.region = Rect2(bound_player.character_color * 48, bound_player.character_type * 48, 48, 48)

func down_pressed():
	sound.play()
	if is_in_lobby:
		timer = 6
		button_down.texture.region.position.y = 32
		bound_player.character_type -= 1
		if bound_player.character_type < 0: bound_player.character_type = 3
		update_stat_text(bound_player.character_type)
		bound_player.change_appearence()
		player_sprite.texture.region = Rect2(bound_player.character_color * 48, bound_player.character_type * 48, 48, 48)

func fire_pressed():
	sound.play()
	if is_in_lobby:
		player_ready = not player_ready
		bound_player.game_manager.set_ready(player_ready)
		if player_ready:
			label_of_readiness.self_modulate = Color(0.2, 1, 0.2)
			label_of_readiness.text = "Ready"
		else:
			label_of_readiness.self_modulate = Color(0.5, 0, 0)
			label_of_readiness.text = "Not ready"

func update_stat_text(c_type: int) -> void:
	stat_panel.text = ""
	text_to_print = character_type_descriptions[c_type]
	printing_progress = 0

func update_stat_text_process() -> void:
	for i in range(2):
		if printing_progress == -1: return
		stat_panel.text += text_to_print[printing_progress]
		if text_to_print[printing_progress] == ".":
			stat_panel.text += "\r\n"
		printing_progress += 1
		if printing_progress == text_to_print.length():
			printing_progress = -1

func _physics_process(_delta: float) -> void:
	update_stat_text_process()
	if timer > 0:
		timer -= 1
	if timer == 1:
		button_up.texture.region.position.y = 0
		button_down.texture.region.position.y = 0
		button_left.texture.region.position.y = 0
		button_right.texture.region.position.y = 0
