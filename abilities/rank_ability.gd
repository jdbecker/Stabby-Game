class_name RankAbility
extends RefCounted

# Minimal RankAbility strategy factory + implementations for Phase 2.
# Abilities mutate the Game via its public helpers so existing validation (wounds/capture)
# remains in place.

static func for_rank(rank: int) -> RankAbility:
	match rank:
		CharacterStats.Rank.ASSASSIN:
			return AssassinAbility.new()
		CharacterStats.Rank.MENTALIST:
			return MentalistAbility.new()
		CharacterStats.Rank.BERSERKER:
			return BerserkerAbility.new()
		CharacterStats.Rank.GUARDIAN:
			return GuardianAbility.new()
		CharacterStats.Rank.MAGE:
			return MageAbility.new()
		CharacterStats.Rank.COURTESAN:
			return CourtesanAbility.new()
		CharacterStats.Rank.ELDER:
			return ElderAbility.new()
		CharacterStats.Rank.ALCHEMIST:
			return AlchemistAbility.new()
		CharacterStats.Rank.HARLEQUIN:
			return HarlequinAbility.new()
		CharacterStats.Rank.INQUISITOR:
			return InquisitorAbility.new()
		_:
			return null


# Default behavior: no-op
func apply(game: Game, actor: Character, context: AbilityContext) -> void:
	push_error("Ability not yet implemented!")

# Helper to give a card
func _give_ability_card(game: Game, card: AbilityCard, character: Character) -> void:
	game.give_ability_card(card, character)

class AssassinAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.target == null:
			push_error("Assassin requires a target")
			return
		var first_wound := WoundContext.new(actor)
		first_wound.block_ability = true
		context.target.unassigned_wounds.append(first_wound)
		var second_wound := WoundContext.new(actor)
		second_wound.block_ability = true
		context.target.unassigned_wounds.append(second_wound)
		game.set_knife_holder(context.target)

class MentalistAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.target == null:
			push_error("Mentalist requires a target")
			return
		var wound_context := WoundContext.new(actor)
		wound_context.block_ability = true
		wound_context.force_rank = true
		context.target.unassigned_wounds.append(wound_context)
		game.set_knife_holder(context.target)

class BerserkerAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if actor.last_wound == null:
			push_error("Berserker's last_wound is missing!")
			return
		var target := actor.last_wound.attacker
		if target == null:
			push_error("Berserker's last attacker is missing from last_wound!")
			return
		var wound_context := WoundContext.new(actor)
		wound_context.block_ability = true
		actor.last_wound.attacker.unassigned_wounds.append(wound_context)

class GuardianAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.target == null:
			push_error("Guardian requires a target to give a Shield to")
			return
		var existing_shielded_players: Array[Character] = game.characters.filter(func(character: Character): return character.has_shield())
		if actor.has_sword():
			var shield := AbilityCard.Shield.new(actor.get_sword().color)
			_give_ability_card(game, shield, context.target)
		elif !existing_shielded_players.is_empty() and existing_shielded_players.front().get_shield().color == Color.GREEN:
			_give_ability_card(game, AbilityCard.Sword.new(Color.PURPLE), actor)
			_give_ability_card(game, AbilityCard.Shield.new(Color.PURPLE), context.target)
		else:
			_give_ability_card(game, AbilityCard.Sword.new(Color.GREEN), actor)
			_give_ability_card(game, AbilityCard.Shield.new(Color.GREEN), context.target)

class MageAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.target == null:
			push_error("Mage requires a target")
			return
		_give_ability_card(game, AbilityCard.Staff.new(), context.target)
		_give_ability_card(game, AbilityCard.Staff.new(), actor)

class CourtesanAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.target == null:
			push_error("Courtesan requires a target")
			return
		_give_ability_card(game, AbilityCard.Fan.new(), context.target)

class ElderAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		_give_ability_card(game, AbilityCard.Quill.new(), actor)

class AlchemistAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null:
			push_error("Alchemist ability requires context")
			return
		if actor.last_wound == null:
			push_error("Alchemist last_wound is missing!")
			return
		var target := actor.last_wound.intervened_for
		if target == null:
			push_error("Alchemist ability can't be activated without intervened_for in last_wound!")
			return
		if context.heal:
			target.unassigned_heals += 1
		else:
			var wound_context := WoundContext.new(actor)
			wound_context.block_ability = true
			target.unassigned_wounds.append(wound_context)

class HarlequinAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.targets == null or context.targets.size() != 2:
			push_error("Harlequin ability requires context with 2 targets")
			return
		for target in context.targets:
			pass # TODO: when UI is done, reveal target info to actor player

class InquisitorAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.targets == null or context.targets.size() < 2:
			push_error("Inquisitor ability requires context with at least 2 targets")
			return
		var curse_recipients := context.targets
		var true_curse_recipient: Character = curse_recipients.pop_front()
		_give_ability_card(game, AbilityCard.TrueCurse.new(), true_curse_recipient)
		for target in curse_recipients:
			_give_ability_card(game, AbilityCard.FalseCurse.new(), target)
