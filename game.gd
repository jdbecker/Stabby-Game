class_name Game
extends Node

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

var characters: Array[Character]
var knife_holder: Character
var last_wounded_character: Character
var _dev_panel: DevPanel


func _init(player_count: int = 7) -> void:
	start_new_game(player_count)


func start_new_game(player_count: int) -> void:
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
	
	characters.shuffle()
	for i in range(characters.size()):
		var character := characters[i]
		character.name = "Player%s" % i
	
	knife_holder = characters[randi() % characters.size()]
	if _dev_panel != null:
		_dev_panel.setup(characters, knife_holder)
	_update_dev_panel()


func activate_ability(character: Character, context: AbilityContext = null) -> void:
	var ability := RankAbility.for_rank(character.rank)
	if ability == null:
		push_error("No RankAbility available for rank %s" % character.rank)
		return
	ability.apply(self, character, context)
	character.unused_ability = false
	_update_dev_panel()


func _ready() -> void:
	_dev_panel = get_node_or_null("DevPanel")
	if _dev_panel == null:
		return
	_dev_panel.new_game_requested.connect(start_new_game)
	_dev_panel.give_dagger_requested.connect(set_knife_holder)
	_dev_panel.add_wound_requested.connect(_on_add_wound_requested)
	_dev_panel.remove_wound_requested.connect(remove_wound)
	_dev_panel.capture_requested.connect(capture)
	_dev_panel.clear_wounds_requested.connect(clear_wounds)
	_dev_panel.setup(characters, knife_holder)


func _on_add_wound_requested(character: Character, wound_type: CharacterStats.Wound) -> void:
	var wound_context := WoundContext.new(knife_holder)
	wound_context.wound_type = wound_type
	suffer_wound(character, wound_context)


func get_other_characters(...exclude_characters: Array) -> Array[Character]:
	var other_characters: Array[Character] = []
	for character: Character in characters:
		if character not in exclude_characters:
			other_characters.append(character)
	return other_characters


func get_valid_stab_targets() -> Array[Character]:
	return get_other_characters(knife_holder).filter(func(character: Character):
		# filter-out shielded characters with guardian not-fully wounded
		return not (
			character.has_shield() and
			self.has_character_with_matching_sword(character.get_shield().color) and
			self.get_character_with_matching_sword(character.get_shield().color).wound_count() < 3)
	)


func has_character_with_matching_sword(color: Color) -> bool:
	return characters.any(func(character: Character):
		return character.has_sword() and character.get_sword().color == color
	)


func get_character_with_matching_sword(color: Color) -> Character:
	return characters.filter(func(character: Character):
		return character.has_sword() and character.get_sword().color == color
	).front()


func set_knife_holder(c: Character) -> void:
	knife_holder = c
	_update_dev_panel()


func suffer_wound(c: Character, wound_context: WoundContext) -> void:
	var wound := wound_context.wound_type
	if wound == null:
		push_error("Character can't suffer wound without type!")
		return
	if wound not in c.valid_new_wounds():
		push_error("%s not in valid wounds for character %s: %s" % [wound, c, c.valid_new_wounds()])
		return
	c.take_wound(wound_context)
	last_wounded_character = c
	set_knife_holder(c)


func capture(c: Character) -> void:
	c.is_captured = true
	_update_dev_panel()


func remove_wound(c: Character, wound: CharacterStats.Wound) -> void:
	var idx := c.wounds.find(wound)
	if idx == -1:
		return
	c.wounds.remove_at(idx)
	_update_dev_panel()


func clear_wounds(c: Character) -> void:
	c.wounds.clear()
	c.is_captured = false
	_update_dev_panel()


func give_ability_card(card: AbilityCard, character: Character) -> void:
	character.ability_cards.append(card)
	_update_dev_panel()


func _update_dev_panel() -> void:
	if _dev_panel != null:
		_dev_panel.update_state(knife_holder)


func clan_leader(clan: CharacterStats.Clan) -> Character:
	var clan_chars := characters.filter(func(character: Character): return character.clan == clan)
	clan_chars.sort_custom(func(a: Character, b: Character): return a.rank < b.rank)
	var maybe_leader: Character = clan_chars.front()
	if maybe_leader.has_quill():
		return clan_chars.back()
	else:
		return maybe_leader
