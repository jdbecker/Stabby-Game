class_name Character
extends RefCounted
## Dynamic data representing the current state of a character during the course of play

signal pass_knife(to: Character)

var wounds: Array[CharacterStats.Wound] = []
var captured: bool = false
# Instead of 2 types of Inquisitors (one for each clue color) we're treating clue color as dynamic
# data that is set when the character is initialized
var clue_color: CharacterStats.Clan
var _stats: CharacterStats


func _init(character_stats: CharacterStats) -> void:
	_stats = character_stats
	clue_color = character_stats.get_clue_color()


func _to_string() -> String:
	return "<%s %s>" % [CharacterStats.Clan.keys()[_stats.clan], CharacterStats.Rank.keys()[_stats.rank]]


func take_wound(wound: CharacterStats.Wound) -> void:
	var remaining_wounds := valid_new_wounds()
	if wound not in remaining_wounds:
		push_error("Character %s cannot take wound %s! Valid wounds are %s" % [self, CharacterStats.Wound.keys()[wound], wounds_to_string(remaining_wounds)])
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


func activate_ability() -> void:
	pass # todo


func valid_new_wounds() -> Array[CharacterStats.Wound]:
	var valid_wounds := _stats.wounds.duplicate()
	for wound: CharacterStats.Wound in wounds:
		var idx := valid_wounds.find(wound)
		if idx == -1:
			push_error("Character %s somehow has a wound %s which its character type is not allowed! Valid wounds for this character type: %s" % [
				self, CharacterStats.Wound.keys()[wound], wounds_to_string(_stats.wounds)
			])
			continue
		valid_wounds.remove_at(idx)
	return valid_wounds
