class_name Character
extends RefCounted
## Dynamic data representing the current state of a character during the course of play

var wounds: Array[CharacterStats.Wound] = []
var unassigned_wounds := 0
var unassigned_heals := 0
var captured: bool = false
# Instead of 2 types of Inquisitors (one for each clue color) we're treating clue color as dynamic
# data that is set when the character is initialized
var clue_color: CharacterStats.Clan
var _stats: CharacterStats
var ability_cards: Array[AbilityCard] = []


func _init(character_stats: CharacterStats) -> void:
	_stats = character_stats
	clue_color = character_stats.get_clue_color()


func _to_string() -> String:
	return "<%s %s>" % [CharacterStats.Clan.keys()[_stats.clan], CharacterStats.Rank.keys()[_stats.rank]]


func take_wound(wound: CharacterStats.Wound) -> void:
	var remaining_wounds := valid_new_wounds()
	if wound not in remaining_wounds:
		push_error("Character %s cannot take wound %s! Valid wounds are %s" % [self, CharacterStats.Wound.keys()[wound], wounds_to_string(remaining_wounds)])
		return
	wounds.append(wound)


func wounds_to_string(wounds_array: Array[CharacterStats.Wound]) -> String:
	var output := "[ "
	for wound: CharacterStats.Wound in wounds_array:
		output += CharacterStats.Wound.keys()[wound] + " "
	return output + "]"


func can_intervene() -> bool:
	return CharacterStats.Wound.RANK in valid_new_wounds()


func wound_count() -> int:
	return wounds.size()


func is_captured() -> bool:
	return captured


func activate_ability(game: Game, ctx: AbilityContext = null) -> void:
	# Dispatch to the RankAbility strategy for this character's rank.
	var ability := RankAbility.for_rank(_stats.rank)
	if ability == null:
		push_error("No RankAbility available for rank %s" % _stats.rank)
		return
	ability.apply(game, self, ctx)


func valid_new_wounds() -> Array[CharacterStats.Wound]:
	var valid_wounds := _stats.wounds.duplicate()
	for wound: CharacterStats.Wound in wounds:
		var any_index := valid_wounds.find(CharacterStats.Wound.ANY)
		var wound_index := valid_wounds.find(wound)
		if any_index != -1 and wound in [CharacterStats.Wound.RED, CharacterStats.Wound.BLUE, CharacterStats.Wound.UNKNOWN]:
			# If the character has a literal RED or BLUE wound, remove an ANY.
			valid_wounds.remove_at(any_index)
		elif wound_index != -1:
			# Remove the wound from the valid list if it exists.
			valid_wounds.remove_at(wound_index)
		else:
			push_error("Character %s somehow has a wound %s which its character type is not allowed! Valid wounds for this character type: %s" % [
				self, CharacterStats.Wound.keys()[wound], wounds_to_string(_stats.wounds)
			])
			continue
	
	var remaining_valid_wounds: Array[CharacterStats.Wound] = []
	for wound: CharacterStats.Wound in valid_wounds:
		if wound == CharacterStats.Wound.ANY:
			# Any records are valid as either clue color, but literal ANY is not.
			remaining_valid_wounds.append(CharacterStats.Wound.RED)
			remaining_valid_wounds.append(CharacterStats.Wound.BLUE)
			remaining_valid_wounds.append(CharacterStats.Wound.UNKNOWN)
		else:
			remaining_valid_wounds.append(wound)
	return remaining_valid_wounds


func has_quill() -> bool:
	return ability_cards.any(func(card: AbilityCard): return card is AbilityCard.Quill)


func has_sword() -> bool:
	return ability_cards.any(func(card: AbilityCard): return card is AbilityCard.Sword)


func get_sword() -> AbilityCard.Sword:
	return ability_cards.filter(func(card: AbilityCard): return card is AbilityCard.Sword).front()


func has_shield() -> bool:
	return ability_cards.any(func(card: AbilityCard): return card is AbilityCard.Shield)


func get_shield() -> AbilityCard.Shield:
	return ability_cards.filter(func(card: AbilityCard): return card is AbilityCard.Shield).front()


func has_staff() -> bool:
	return ability_cards.any(func(card: AbilityCard): return card is AbilityCard.Staff)


func has_fan() -> bool:
	return ability_cards.any(func(card: AbilityCard): return card is AbilityCard.Fan)


func has_true_curse() -> bool:
	return ability_cards.any(func(card: AbilityCard): return card is AbilityCard.TrueCurse)


func has_false_curse() -> bool:
	return ability_cards.any(func(card: AbilityCard): return card is AbilityCard.FalseCurse)
