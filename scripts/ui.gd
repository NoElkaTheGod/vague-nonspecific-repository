class_name UI extends Control

@onready var game_manager: GameManager = get_parent().get_parent()
@onready var countdown := $Countdown
@onready var countdown_sound := $Countdown/CountdownSoundEmitter
@onready var countdown_end_sound := $Countdown/CountdownEndSoundEmitter

func _ready() -> void:
	get_viewport().connect("size_changed", viewport_size_changed)
	viewport_size_changed()

func viewport_size_changed() -> void:
	size = get_viewport_rect().size

func _physics_process(_delta: float) -> void:
	if game_manager.round_start_countdown != -1: update_countdown()

func update_countdown() -> void:
	var time = game_manager.round_start_countdown
	if time == 80:
		countdown.modulate = Color(1, 1, 1, 1)
		countdown.visible = true
		countdown_sound.play()
		countdown.texture.region.position.y = 0
	if time == 60 or time == 40:
		countdown_sound.play()
		countdown.texture.region.position.y += 128
	if time == 20:
		countdown_end_sound.play()
		countdown.texture.region.position.y += 128
	if time <= 20:
		countdown.modulate = Color(1, 1, 1, time / 20.0)
	if time == 0:
		countdown.visible = false
