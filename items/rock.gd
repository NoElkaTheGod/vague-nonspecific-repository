class_name rock_item extends Action


func _ready() -> void:
	texture = "res://sprites/items/rock_item.png"
	item_name = "Камень."
	description = "Это... камень.\r\nМожет наносить урон, если хорошенько разогнать.\r\n+1 секунда перезарядки. 0.17 секунды задержки действия."
	use_delay = 10
	weight = 0.3
	associated_scene = load("res://scenes/meteor_smol.tscn")

func action(actor: Player) -> int:
	actor.reload_offset += 60
	var rock: RigidBody2D = associated_scene.instantiate()
	actor.game_manager.projectile_container.add_child(rock)
	rock.position = actor.position + (Vector2(cos(actor.rotation), sin(actor.rotation)) * 70).rotated(actor.angle_offset)
	rock.linear_velocity = (Vector2(cos(actor.rotation), sin(actor.rotation)) * 250).rotated(actor.angle_offset) * actor.projectile_velocity_multiplier + actor.linear_velocity
	actor.linear_velocity += Vector2(cos(actor.rotation), sin(actor.rotation)).rotated(actor.angle_offset + PI) * 80.0 * actor.recoil_multiplier
	for component in components:
		rock.add_child(component)
	components.clear()
	component_classes.clear()
	return use_delay
