class_name Attractor extends Repulsor

@onready var sound = $AudioStreamPlayer

func _ready() -> void:
	connect("body_entered", contact)
	$AnimatedSprite2D.play()

func contact(body: Node2D) -> void:
	if body is not RigidBody2D: return
	var pebis := body as RigidBody2D
	pebis.linear_velocity = (pebis.position - position).normalized() * 1000# / pebis.mass
	pebis.angular_velocity += 50 / pebis.mass
	sound.play()
