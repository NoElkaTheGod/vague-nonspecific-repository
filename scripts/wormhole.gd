class_name Wormhole extends Area2D

var linked_wormhole: Wormhole
var activation_cd := 30
var displaying_line := 0
@onready var particles := $GPUParticles2D
@onready var sprite := $Sprite2D
@onready var sound := $AudioStreamPlayer

func _ready() -> void:
	connect("body_entered", teleprot)

func enter_cd() -> void:
	activation_cd = 30

func teleprot(body: Node2D) -> void:
	if activation_cd > 0: return
	enter_cd()
	linked_wormhole.enter_cd()
	body.global_position += linked_wormhole.global_position - global_position
	sound.play()
	displaying_line = 20
	queue_redraw()

func _draw() -> void:
	if displaying_line > 0:
		draw_line(Vector2.ZERO, linked_wormhole.global_position - global_position, modulate * Color(1, 1, 1, displaying_line / 10.0), 4)

func _process(_delta: float) -> void:
	sprite.rotate(0.02 + (activation_cd / 100.0))

func _physics_process(_delta: float) -> void:
	if displaying_line > 0:
		displaying_line -= 1
		queue_redraw()
	if activation_cd > 0:
		activation_cd -= 1
