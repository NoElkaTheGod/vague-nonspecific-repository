class_name HealthBar extends Control

var HP: float
var max_HP: float
var time_since_last_damage: int
var last_damage: float

var bound_player: Player
var offset := Vector2(0, -60)

@onready var box := $Box
@onready var red := $Box/Red
@onready var white := $Box/White
@onready var dark := $Box/Dark

func init(_max_HP: int, player: Player, color := Color(0.6, 0, 0), new_offset := Vector2(0, -60)) -> void:
	red.modulate = color
	dark.modulate = color
	offset = new_offset
	max_HP = _max_HP
	HP = player.hit_points
	time_since_last_damage = 0
	last_damage = 0
	bound_player = player

func damage_taken(damage: int) -> void:
	last_damage += damage
	HP -= damage
	time_since_last_damage = 0

var timer: float

func _process(delta: float) -> void:
	visible = bound_player.sprite.visible and bound_player.visible and HP > 0
	position = bound_player.position + offset - (size / 2.0)
	timer += delta
	if timer >= 0.5:
		timer -= 1
		time_since_last_damage += 1
	if time_since_last_damage > 1 and last_damage > 0:
		last_damage -= 0.5
	white.custom_minimum_size.x = last_damage / max_HP * box.size.x
	dark.custom_minimum_size.x =  (max_HP - HP - last_damage) / max_HP * box.size.x
