class_name CooldownIndicator extends Control

var bound_player: Player
var opacity := 1.0
var full_stack_size := 0.0
var cur_stack_size := 0.0
var reload_time := 0.0
var reload_timer := 0.0

@onready var reload_bar := $ReloadBar/Dark
@onready var cooldown_bar := $CooldownBar
@onready var box := $ReloadBar

func init(player: Player) -> void:
	bound_player = player

func _physics_process(_delta: float) -> void:
	if bound_player == null: return
	visible = bound_player.sprite_base.visible and bound_player.visible
	if cooldown_bar.value < cooldown_bar.max_value:
		opacity = 1.0
		cooldown_bar.value += 1
	else:
		opacity = lerp(opacity, 0.0, 0.1)
	cooldown_bar.modulate = Color(1, 1, 1, opacity)
	if reload_timer < reload_time:
		reload_timer += 1
	elif reload_time > 0.0:
		reload_timer = 0
		reload_time = 0
		cur_stack_size = full_stack_size

func _process(_delta: float) -> void:
	if reload_time > 0:
		reload_bar.custom_minimum_size.x = (1 - (reload_timer / reload_time)) * box.size.x
	else:
		reload_bar.custom_minimum_size.x = (1 - (cur_stack_size / full_stack_size)) * box.size.x
	reload_bar.custom_minimum_size.x = clamp(reload_bar.custom_minimum_size.x, 0, 40)

func start_cooldown(length: int) -> void:
	cooldown_bar.value = 0
	cooldown_bar.max_value = length

func action_fired() -> void:
	if reload_time > 0.0:
		reload_timer = 0
		reload_time = 0
		cur_stack_size = full_stack_size
	cur_stack_size -= 1

func reload_started(time: int) -> void:
	reload_timer = 0
	reload_time = time

func set_max_stack_size(stack_size: int) -> void:
	full_stack_size = stack_size
	cur_stack_size = stack_size
