class_name homing_component extends BaseComponent

var parent: PhysicsBody2D
var hitbox: Area2D
var sprite: Sprite2D
var strength: float = 50
var scale: float = 1.0
var target: Node2D
var actor: Node2D
const content_path = "res://scenes/homing_component_content.tscn"

func _ready() -> void:
	parent = get_parent()
	hitbox = load(content_path).instantiate()
	parent.add_child(hitbox)
	hitbox.global_position = parent.global_position
	sprite = hitbox.get_node("Sprite2D")
	hitbox.connect("body_entered", target_detected)
	hitbox.connect("body_exited", target_lost)

func _physics_process(_delta: float) -> void:
	hitbox.scale = Vector2(scale, scale)
	if target == null: return
	if parent is CharacterBody2D:
		parent.velocity += (target.position - parent.position).normalized() * strength
	elif parent is RigidBody2D:
		parent.linear_velocity += (target.position - parent.position).normalized() * strength

func target_detected(body: Node2D) -> void:
	if body is not Player: return
	if body == actor: return
	target = body
	sprite.modulate = Color(1, 0.3, 0.3)

func target_lost(body: Node2D) -> void:
	if body is not Player: return
	if body == actor: return
	target = null
	sprite.modulate = Color(1, 1, 1)

func terminate() -> void:
	hitbox.queue_free()
	queue_free()
