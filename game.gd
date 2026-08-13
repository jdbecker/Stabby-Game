class_name Game
extends RefCounted

const INQUISITOR := preload("uid://drrilkp3puywx")
const BLUE_ELDER := preload("uid://6v6gjjk8ok0b")
const BLUE_ASSASSIN := preload("uid://d0il84d6irqom")
const BLUE_HARLEQUIN := preload("uid://o3ii7ityuit0")
const BLUE_ALCHEMIST := preload("uid://buh17miapimkg")
const BLUE_MENTALIST := preload("uid://dxirlibw0q6q6")
const BLUE_GUARDIAN := preload("uid://crhoowchjbjnr")
const BLUE_BERSERKER := preload("uid://7ns25yjhnh40")
const BLUE_MAGE := preload("uid://fw8unmo8nw3")
const BLUE_COURTESAN := preload("uid://43obyka5ym2b")
const RED_ELDER := preload("uid://cpjkdywtlbdm4")
const RED_ASSASSIN := preload("uid://blfvikhc03hs")
const RED_HARLEQUIN := preload("uid://bt5l56ke6lyma")
const RED_ALCHEMIST := preload("uid://do7ass0ysvo3m")
const RED_MENTALIST := preload("uid://bltyofn7bhu5p")
const RED_GUARDIAN := preload("uid://cy1tatuwaev7m")
const RED_BERSERKER := preload("uid://cnieqoddi6xpu")
const RED_MAGE := preload("uid://dlfjpx087qyg1")
const RED_COURTESAN := preload("uid://dqtjc3j541qq8")
const ALL_CHARACTERS: Array[CharacterStats] = [
	INQUISITOR,
	BLUE_ELDER,
	BLUE_ASSASSIN,
	BLUE_HARLEQUIN,
	BLUE_ALCHEMIST,
	BLUE_MENTALIST,
	BLUE_GUARDIAN,
	BLUE_BERSERKER,
	BLUE_MAGE,
	BLUE_COURTESAN,
	RED_ELDER,
	RED_ASSASSIN,
	RED_HARLEQUIN,
	RED_ALCHEMIST,
	RED_MENTALIST,
	RED_GUARDIAN,
	RED_BERSERKER,
	RED_MAGE,
	RED_COURTESAN
]
const RED_CHARACTERS: Array[CharacterStats] = [
	RED_ELDER,
	RED_ASSASSIN,
	RED_HARLEQUIN,
	RED_ALCHEMIST,
	RED_MENTALIST,
	RED_GUARDIAN,
	RED_BERSERKER,
	RED_MAGE,
	RED_COURTESAN
]
const BLUE_CHARACTERS: Array[CharacterStats] = [
	BLUE_ELDER,
	BLUE_ASSASSIN,
	BLUE_HARLEQUIN,
	BLUE_ALCHEMIST,
	BLUE_MENTALIST,
	BLUE_GUARDIAN,
	BLUE_BERSERKER,
	BLUE_MAGE,
	BLUE_COURTESAN,
]

signal state_changed

var characters: Array[Character]
var knife_holder: Character
var stab_target: Character : set = _set_stab_target
var intervention_offers: Array[Character]


func _init(player_count: int) -> void:
	if player_count < 6 or 12 < player_count:
		push_error("Invalid player_count: %s. Must be between 6 and 12 players!" % player_count)
		return
	characters = []
	var inquisitor := player_count % 2
	var reds_and_blues := floori((player_count - inquisitor) / 2.0)
	var candidates: Array[CharacterStats] = []
	candidates = RED_CHARACTERS.duplicate() as Array[CharacterStats]
	candidates.shuffle()
	characters.append_array(candidates.slice(0, reds_and_blues).map(func(c: CharacterStats): return Character.new(c)))
	candidates = BLUE_CHARACTERS.duplicate() as Array[CharacterStats]
	candidates.shuffle()
	characters.append_array(candidates.slice(0, reds_and_blues).map(func(c: CharacterStats): return Character.new(c)))
	if inquisitor:
		characters.append(Character.new(INQUISITOR))
	assert(characters.size() == player_count, "Couldn't create correct number of characters! Characters: %s" % str(characters))
	
	knife_holder = characters[randi() % characters.size()]


func get_other_characters(...exclude_characters: Array) -> Array[Character]:
	var other_characters: Array[Character] = []
	for character: Character in characters:
		if character not in exclude_characters:
			other_characters.append(character)
	return other_characters


func _set_stab_target(target: Character) -> void:
	intervention_offers = [] # clear intervention offers when target changes
	stab_target = target


func set_knife_holder(c: Character) -> void:
	knife_holder = c
	state_changed.emit()


func suffer_wound(c: Character, wound: CharacterStats.Wound) -> void:
	if c.is_captured():
		return
	if c.valid_new_wounds().is_empty():
		c.captured = true
		state_changed.emit()
		return
	if wound not in c.valid_new_wounds():
		return
	c.take_wound(wound)
	state_changed.emit()


func remove_wound(c: Character, wound: CharacterStats.Wound) -> void:
	var idx := c.wounds.find(wound)
	if idx == -1:
		return
	c.wounds.remove_at(idx)
	if c.captured and not c.valid_new_wounds().is_empty():
		c.captured = false
	state_changed.emit()


func clear_wounds(c: Character) -> void:
	c.wounds.clear()
	c.captured = false
	state_changed.emit()


func give_ability_card(card: AbilityCard, character: Character) -> void:
	character.ability_cards.append(card)
	state_changed.emit()
