extends Node2D

@export var alpha: CurveTexture
@export var color: Gradient
@onready var sprite := $Sprite2D
var timer := -1
var duration := 0

func _physics_process(delta: float) -> void:
	if timer == -1: return
	if timer == duration: stop_anim()
	rotate(get_parent().angular_velocity * -1 * delta)
	timer += 1
	sprite.modulate = Color(color.sample(float(timer) / float(duration)), alpha.curve.sample(float(timer) / float(duration)))

func _process(delta: float) -> void:
	if timer == -1: return
	sprite.rotate(2 * delta)

func start_anim(_duration: int) -> void:
	duration = _duration
	timer = 0

func stop_anim() -> void:
	sprite.modulate = Color(1,1,1,0)
	var fodder = $Area2D.get_overlapping_bodies()
	for item in fodder:
		if item is not Player: continue
		var achtung = item as Player
		achtung.linear_velocity += (achtung.position - position).normalized() * 100
		achtung.start_dying(self)
	timer = -1
	$GPUParticles2D.emitting = true
	$Shockwave.do_thing()
