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
@onready var inventory_container := $NotLobbyButtons/GridContainer
@onready var button_up := $LobbyButtons/Up
@onready var button_down := $LobbyButtons/Down
@onready var button_left := $LobbyButtons/Left
@onready var button_right := $LobbyButtons/Right
@onready var stat_panel := $Stats
@onready var sound := $PressDoundEmitter

var inventory_panels: Array[Panel]
var inventory_icons: Array[TextureRect]
var selected_button := Vector2i.ZERO
var selected_slot := Vector2i.ONE * -1

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
		inventory_container.columns = player.action_stack_size
		inventory_panels.resize(player.action_stack_size * (player.inventory_rows + 1))
		inventory_icons.resize(player.action_stack_size * (player.inventory_rows + 1))
		for old in inventory_container.get_children():
			old.queue_free()
		for i in range(player.action_stack_size * player.amount_of_stacks):
			var new_slot = Panel.new()
			new_slot.custom_minimum_size = Vector2(48, 48)
			inventory_container.add_child(new_slot)
			new_slot.z_index = 1
			inventory_panels[i] = new_slot
			new_slot.self_modulate = Color(1.8, 1.8, 1.8)
			var new_slot_sprite = TextureRect.new()
			new_slot_sprite.custom_minimum_size = Vector2(48, 48)
			new_slot.add_child(new_slot_sprite)
			new_slot_sprite.z_index = 2
			inventory_icons[i] = new_slot_sprite
			if player.inventory[i] == null: continue
			new_slot_sprite.texture = load(player.inventory[i].texture)
		for i in range(player.action_stack_size * player.inventory_rows):
			var new_slot = Panel.new()
			new_slot.custom_minimum_size = Vector2(48, 48)
			inventory_container.add_child(new_slot)
			new_slot.z_index = 1
			inventory_panels[i + player.action_stack_size] = new_slot
			var new_slot_sprite = TextureRect.new()
			new_slot_sprite.custom_minimum_size = Vector2(48, 48)
			new_slot.add_child(new_slot_sprite)
			new_slot_sprite.z_index = 2
			inventory_icons[i + player.action_stack_size] = new_slot_sprite
			if player.inventory[i + player.action_stack_size] == null: continue
			new_slot_sprite.texture = load(player.inventory[i + player.action_stack_size].texture)
		await inventory_container.sort_children
		other_buttons.custom_minimum_size = inventory_container.size
		selected_button = Vector2i.ZERO
		update_inv_highlight(selected_button, Color(1.5, 1.5, 1.5))
		selected_slot = Vector2i.ONE * -1

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
	else:
		update_inv_highlight(selected_button, Color(1.0, 1.0, 1.0))
		selected_button.x -= 1
		if selected_button.x < 0: selected_button.x = bound_player.action_stack_size - 1
		update_inv_highlight(selected_button, Color(1.5, 1.5, 1.5))

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
	else:
		update_inv_highlight(selected_button, Color(1.0, 1.0, 1.0))
		selected_button.x += 1
		if selected_button.x > bound_player.action_stack_size - 1: selected_button.x = 0
		update_inv_highlight(selected_button, Color(1.5, 1.5, 1.5))

func up_pressed():
	sound.play()
	if is_in_lobby:
		timer = 6
		button_up.texture.region.position.y = 32
		bound_player.character_type += 1
		if bound_player.character_type > 3: bound_player.character_type = 0
		update_stat_text(bound_player.character_type)
		bound_player.change_appearence()
		bound_player.change_player_type(bound_player.character_type)
		player_sprite.texture.region = Rect2(bound_player.character_color * 48, bound_player.character_type * 48, 48, 48)
	else:
		update_inv_highlight(selected_button, Color(1.0, 1.0, 1.0))
		selected_button.y -= 1
		if selected_button.y < -1: selected_button.y = bound_player.inventory_rows
		update_inv_highlight(selected_button, Color(1.5, 1.5, 1.5))

func down_pressed():
	sound.play()
	if is_in_lobby:
		timer = 6
		button_down.texture.region.position.y = 32
		bound_player.character_type -= 1
		if bound_player.character_type < 0: bound_player.character_type = 3
		update_stat_text(bound_player.character_type)
		bound_player.change_appearence()
		bound_player.change_player_type(bound_player.character_type)
		player_sprite.texture.region = Rect2(bound_player.character_color * 48, bound_player.character_type * 48, 48, 48)
	else:
		update_inv_highlight(selected_button, Color(1.0, 1.0, 1.0))
		selected_button.y += 1
		if selected_button.y > bound_player.inventory_rows: selected_button.y = -1
		update_inv_highlight(selected_button, Color(1.5, 1.5, 1.5))

func fire_pressed():
	sound.play()
	if is_in_lobby or selected_button.y == -1:
		toggle_ready()
		selected_slot = Vector2i.ONE * -1
	else:
		if selected_slot != Vector2i.ONE * -1:
			var first_slot: int = selected_slot.x + (selected_slot.y * bound_player.action_stack_size)
			var second_slot: int = selected_button.x + (selected_button.y * bound_player.action_stack_size)
			var temp: Action = bound_player.inventory[first_slot]
			bound_player.inventory[first_slot] = bound_player.inventory[second_slot]
			bound_player.inventory[second_slot] = temp

			if bound_player.inventory[first_slot] == null:
				inventory_icons[first_slot].texture = null
			else:
				inventory_icons[first_slot].texture = load(bound_player.inventory[first_slot].texture)

			if bound_player.inventory[second_slot] == null:
				inventory_icons[second_slot].texture = null
			else:
				inventory_icons[second_slot].texture = load(bound_player.inventory[second_slot].texture)

			selected_slot = Vector2i.ONE * -1
		elif bound_player.inventory[selected_button.x + (selected_button.y * bound_player.action_stack_size)] != null:
			selected_slot = selected_button

func toggle_ready() -> void:
		player_ready = not player_ready
		bound_player.game_manager.set_ready(player_ready)
		if player_ready:
			label_of_readiness.self_modulate = Color(0.2, 1, 0.2)
			label_of_readiness.text = "Ready"
		else:
			label_of_readiness.self_modulate = Color(0.5, 0, 0)
			label_of_readiness.text = "Not ready"
	
func update_inv_highlight(pos: Vector2i, mod: Color):
	if pos.y == -1:
		label_of_readiness.modulate = mod
	else:
		inventory_panels[pos.x + (pos.y * bound_player.action_stack_size)].modulate = mod

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
