class_name AttackContext
extends RefCounted

var attacker: Character
var target: Character
var might_intervene: Array[Character]
var cant_intervene: Array[Character]
var offered_intervene: Array[Character]


func _init(attacker: Character, target: Character, other_characters: Array[Character]) -> void:
	self.attacker = attacker
	self.target = target
	for character: Character in other_characters:
		if character.can_intervene():
			might_intervene.append(character)
		else:
			cant_intervene.append(character)
