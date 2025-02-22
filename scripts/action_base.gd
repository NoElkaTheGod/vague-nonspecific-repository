class_name Action extends Node

enum item_types {
	ACTION,
	MODIFIER
}
var item_type := item_types.ACTION
var weight := 0.0

var texture:= ""
var item_name := ""
var description := ""
var use_delay := 0

func action(_actor: Player) -> int:
	return 0

func compile_into_stack(stack: Array) -> void:
	stack.push_front(self)
