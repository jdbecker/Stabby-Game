class_name AbilityContext
extends RefCounted
## Simple context object passed into abilities.

var target: Character : get = _get_target, set = _set_target
var targets: Array[Character] = []
var intervention: bool = false
var heal: bool = false


func _get_target() -> Character:
	return targets.front()


func _set_target(character: Character) -> void:
	targets = [character]
