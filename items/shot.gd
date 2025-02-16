class_name shot_item extends Action

var amount := 1

func _ready() -> void:
	texture = "res://sprites/items/shot_item.png"
	item_name = "Снаряд"
	description = "Самый обычный снаряд."
	use_delay = 10

func action(actor: Player) -> int:
	if actor.idle_projectile_manager == null: return 20
	actor.shot_sound_emitter.play()
	var additional_rotation: Array[float]
	additional_rotation.resize(amount)
	for i in range(amount):
		additional_rotation[i] = deg_to_rad(((i - (amount / 2.0 - 0.5)) * 10))
	for i in range(amount):
		var proj: projectile = actor.idle_projectile_manager.get_idle_projectile()
		proj.init()
		proj.visible = true
		proj.process_mode = Node.PROCESS_MODE_PAUSABLE
		proj.position = actor.position + (Vector2(cos(actor.rotation), sin(actor.rotation)) * 50)
		proj.velocity = (Vector2(cos(actor.rotation + additional_rotation[i]), sin(actor.rotation + additional_rotation[i])) * randf_range(550, 650)) + actor.linear_velocity
	return use_delay
