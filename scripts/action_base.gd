class_name Action extends Node

enum ITEM_TYPE {
	ACTION,
	MODIFIER
}
var item_type := ITEM_TYPE.ACTION
var weight := 0.0
var trigger_next_immediately := false
var components: Array[Node]
var component_classes: Array

var texture:= ""
var item_name := ""
var description := ""
var use_delay := 0

func action(_actor: Player) -> int:
	return 0

func compile_into_stack(stack: Array) -> int:
	stack.push_front(self)
	return 0

func add_component(component) -> BaseComponent:
	if trigger_next_immediately or item_type == ITEM_TYPE.MODIFIER: return
	var new_comp = component.new()
	component_classes.append(component)
	components.append(new_comp)
	return new_comp

func has_component(component) -> bool:
	for item in component_classes:
		if item == component:
			return true
	return false
