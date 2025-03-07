class_name HealthBar extends Control

var HP: float
var max_HP: float
var time_since_last_damage: int
var last_damage: float

var bound_player: Player

@onready var box := $Box
@onready var red := $Box/Red
@onready var white := $Box/White
@onready var dark := $Box/Dark

func init(_max_HP: int, player: Player, color := Color(0.6, 0, 0)) -> void:
	red.modulate = color
	dark.modulate = color
	max_HP = _max_HP
	HP = player.hit_points
	time_since_last_damage = 0
	last_damage = 0
	bound_player = player

func damage_taken(damage: float) -> void:
	last_damage += damage
	HP -= damage
	time_since_last_damage = 0

func healing_recieved(amount: float) -> void:
	HP += amount
	last_damage = move_toward(last_damage, 0, amount)
	if HP > max_HP: HP = max_HP

var timer: float

func _process(delta: float) -> void:
	if bound_player == null: return
	if last_damage < 0: last_damage = 0
	if HP < 0: HP = 0
	visible = bound_player.sprite_base.visible and bound_player.visible
	timer += delta
	if timer >= 0.5:
		timer -= 0.5
		time_since_last_damage += 1
	if time_since_last_damage > 1 and last_damage > 0:
		last_damage -= 1
	white.custom_minimum_size.x = last_damage / max_HP * box.size.x
	dark.custom_minimum_size.x =  (max_HP - HP - last_damage) / max_HP * box.size.x
