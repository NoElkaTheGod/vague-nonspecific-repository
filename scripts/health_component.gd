class_name HealthComponent extends Node

@export var hit_points := 0.0
var healthbar: HealthBar = null
@onready var parent = get_parent()
@onready var sound: AudioStreamPlayer = $DamageSound

func take_damage(body: Node2D = null, damage: float = 0):
	hit_points -= damage
	if healthbar != null:
		healthbar.damage_taken(damage)
	if parent is RigidBody2D:
		parent.apply_central_impulse((body.position - parent.position).normalized() * -5 * damage)
	if hit_points > 0:
		sound.play()
	else:
		if parent is Player:
			if parent.death_timer != -1: return
			parent.alarm_sound_emitter.play()
			parent.death_timer = 75
			parent.thruster_particles.emitting = false
		else:
			parent.queue_free()
			var remainder = load("res://scenes/generic_remainder.tscn").instantiate()
			get_node("/root/GameManager/ProjectileContainer").add_child(remainder)
			remainder.position = parent.position
