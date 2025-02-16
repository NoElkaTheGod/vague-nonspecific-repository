class_name mine_item extends Action


func _ready() -> void:
	texture = "res://sprites/items/mine_item.png"
	item_name = "Мина"
	description = "Мина с датчиком движения. Взорвётся, если кто-нибудь приблизится к ней."
	use_delay = 120

func action(actor: Player) -> int:
	actor.mine_release_sound_emitter.play()
	var mine: Mine = actor.idle_projectile_manager.get_idle_mine()
	mine.init()
	mine.visible = true
	mine.process_mode = Node.PROCESS_MODE_PAUSABLE
	mine.position = actor.position + (Vector2(cos(actor.rotation), sin(actor.rotation)) * -50)
	mine.linear_velocity = (Vector2(cos(actor.rotation), sin(actor.rotation)) * randf_range(-200, -150)) + actor.linear_velocity
	return use_delay
