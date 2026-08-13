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

# Assassin: two suffer_wound(target) + set_knife_holder(target)
class AssassinAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.target == null:
			push_error("Assassin requires a target")
			return
		context.target.unassigned_wounds += 2
		game.set_knife_holder(context.target)

# Mentalist: rank wound + dagger
class MentalistAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.target == null:
			push_error("Mentalist requires a target")
			return
		# Prefer RANK; fall back to any available wound
		var preferred := CharacterStats.Wound.RANK
		var choices := context.target.valid_new_wounds()
		if preferred in choices:
			game.suffer_wound(context.target, preferred)
		else:
			context.target.unassigned_wounds += 1
		game.set_knife_holder(context.target)

# Berserker: wound attacker (context.target expected to be attacker)
class BerserkerAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.target == null:
			# nothing to do without attacker information
			return
		context.target.unassigned_wounds += 1

# Guardian: give Shield to target and take a Sword for actor
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

# Mage: give a Staff to target and to actor
class MageAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.target == null:
			push_error("Mage requires a target")
			return
		_give_ability_card(game, AbilityCard.Staff.new(), context.target)
		_give_ability_card(game, AbilityCard.Staff.new(), actor)

# Courtesan: give Fan to target
class CourtesanAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or context.target == null:
			push_error("Courtesan requires a target")
			return
		_give_ability_card(game, AbilityCard.Fan.new(), context.target)

# Elder: receive Quill
class ElderAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		_give_ability_card(game, AbilityCard.Quill.new(), actor)

# Alchemist: can only be used in intervention; wound or heal 1
class AlchemistAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		if context == null or not context.intervention or context.target == null:
			push_error("Alchemist ability requires an intervention context and a target")
			return
		if context.heal:
			context.target.unassigned_heals += 1
		else:
			context.target.unassigned_wounds += 1

# Harlequin: reveal-only / no-op (viewing handled by UI)
class HarlequinAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		# no state mutation for reveal-only ability
		pass

# Inquisitor: hand out curses
class InquisitorAbility:
	extends RankAbility
	func apply(game: Game, actor: Character, context: AbilityContext) -> void:
		var curse_recipients := context.targets
		var true_curse_recipient: Character = curse_recipients.pop_front()
		_give_ability_card(game, AbilityCard.TrueCurse.new(), true_curse_recipient)
		for target in curse_recipients:
			_give_ability_card(game, AbilityCard.FalseCurse.new(), target)
