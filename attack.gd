class_name Attack
extends RefCounted

var intervention_offers: Array[Character] = []

var _attacker: Character
var _target: Character
var _intervener: Character
var _game: Game


func _init(game: Game, attacker: Character, target) -> void:
	_game = game
	_attacker = attacker
	_target = target


func offer_intervention(intervener: Character) -> void:
	if not intervener.can_intervene():
		push_error("Invalid intervener %s! Only a character who hasn't taken a RANK wound can intervene!" % intervener)
		return
	elif intervener in intervention_offers:
		push_error("Invalid intervener %s! Only a character who has not already offered to intervene can intervene!" % intervener)
		return
	else:
		intervention_offers.append(intervener)


func accept_intervention(intervener: Character) -> void:
	if not intervener.can_intervene():
		push_error("Invalid intervener %s! Only a character who hasn't taken a RANK wound can intervene!" % intervener)
		return
	elif intervener not in intervention_offers:
		push_error("Invalid intervener %s! Only a character who has offered to intervene can intervene: %s" % [intervener, intervention_offers])
		return
	else:
		_intervener = intervener


func apply_attack() -> void:
	var wound_context := WoundContext.new(_attacker)
	if _intervener:
		if _intervener.can_intervene():
			wound_context.intervened_for = _target
			wound_context.wound_type = CharacterStats.Wound.RANK
			_game.suffer_wound(_intervener, wound_context)
		else:
			push_error("Impossible intervener! Intervener must still have RANK wound!")
			return
	else:
		_game.set_knife_holder(_target)
		_target.unassigned_wounds.append(wound_context)
