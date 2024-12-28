class_name CollisionSoundEmitter extends Node

func play(sound: int) -> void:
	get_child(sound).play()
