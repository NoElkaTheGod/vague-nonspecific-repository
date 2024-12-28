class_name Powerup extends Area2D

var powerup_type: int
var destination: Vector2
@onready var game_manager: GameManager = get_parent()

func init(type: int, to: Vector2, from: Vector2) -> void:
	powerup_type = type
	position = from
	destination = to
	$Sprite2D.texture.region.position.x = type * 32
	connect("body_entered", consume)

func _physics_process(_delta: float) -> void:
	position = position.move_toward(destination, 1)
	if position == destination: 
		game_manager.powerups.erase(self)
		queue_free()

func consume(body: Node2D) -> void:
	if body is not Player: return
	var achtung = body as Player
	achtung.apply_powerup(powerup_type)
	game_manager.powerups.erase(self)
	queue_free()
