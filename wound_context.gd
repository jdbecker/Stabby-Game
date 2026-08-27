class_name WoundContext
extends RefCounted

var attacker: Character
var intervened_for: Character
var block_ability: bool = false
var force_rank: bool = false
var wound_type: CharacterStats.Wound


func _init(attacker: Character) -> void:
	self.attacker = attacker
