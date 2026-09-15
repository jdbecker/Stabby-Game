class_name PlayerView
extends Control

signal request_stab(target: Character)
signal request_pass_dagger(target: Character)

const CLAN_BLUE_ICON = preload("uid://crs81muwa6whu")
const CLAN_RED_ICON = preload("uid://bufdewe0mkvel")
const CLAN_INQUISITOR_ICON = preload("uid://bs7i8mqh6pwe8")

const WOUND_RANK_1_ICON = preload("uid://cx7lt7jfdi23g")
const WOUND_RANK_2_ICON = preload("uid://c8j4wbiqowyr6")
const WOUND_RANK_3_ICON = preload("uid://cifcdkojfe0il")
const WOUND_RANK_4_ICON = preload("uid://cei80pbnqhbjj")
const WOUND_RANK_5_ICON = preload("uid://cwgd504eivpbd")
const WOUND_RANK_6_ICON = preload("uid://dfdio7ogfbcj8")
const WOUND_RANK_7_ICON = preload("uid://cowgnrfx3h8y1")
const WOUND_RANK_8_ICON = preload("uid://bpdaxmxf4l0f7")
const WOUND_RANK_9_ICON = preload("uid://dxxantue436gn")
const WOUND_RANKINQUISITOR_ICON = preload("uid://b4v2eumb7p7tp")

const WOUND_BLUE_ICON = preload("uid://dgilhq7wk48f4")
const WOUND_RED_ICON = preload("uid://da2qqjuydttxq")
const WOUND_UNKNOWN_ICON = preload("uid://bftmwicr7g3sm")
const WOUND_ANY_ICON = preload("uid://d3ahgtumc0sa")

const CHARACTER_ROW_SCENE = preload("res://ui/character_row_ui.tscn")
const PROMPT = preload("uid://bw8jr3yk4gd46")

var current_character: Character
var all_characters: Array[Character]
var prompts: Array[Prompt]

@onready var player_name_label: Label = %PlayerNameLabel
@onready var clan_color_image: TextureRect = %ClanColorImage
@onready var rank_wound: TextureRect = %RankWound
@onready var alignment_wound_1: TextureRect = %AlignmentWound1
@onready var alignment_wound_2: TextureRect = %AlignmentWound2
@onready var clue_color_image: TextureRect = %ClueColorImage
@onready var game_characters_list: VBoxContainer = %GameCharactersList
@onready var inquisitor_rank_wound: TextureButton = %InquisitorRankWound


func _ready() -> void:
	if not current_character:
		push_error("PlayerView requires current_character to be set!")
	if not all_characters:
		push_error("PlayerView requires all_characters to be set!")
	player_name_label.text = current_character.name
	clan_color_image.texture = _get_clan_color_image(current_character.clan)
	rank_wound.texture = _get_rank_icon(current_character)
	alignment_wound_1.texture = _get_alignment_wound_icon(current_character._stats.wounds[1])
	alignment_wound_2.texture = _get_alignment_wound_icon(current_character._stats.wounds[2])
	clue_color_image.texture = _get_clan_color_image(current_character.clue_color)
	for character in all_characters:
		var character_row := CHARACTER_ROW_SCENE.instantiate() as CharacterRowUI
		character_row.character = character
		game_characters_list.add_child(character_row)
	_view_neighbor_clue_color()
	inquisitor_rank_wound.pressed.connect(func() -> void: self.hide())
	refresh()


func refresh() -> void:
	if not prompts.is_empty():
		prompts.front().visible = true
	for character: CharacterRowUI in game_characters_list.get_children():
		character.refresh()


func add_knife_action_prompt() -> void:
	var prompt := PROMPT.instantiate() as Prompt
	prompt.knife_action(all_characters)
	prompt.request_pass_knife.connect(func(target: Character) -> void: request_pass_dagger.emit(target))
	prompt.request_stab.connect(func(target: Character) -> void: request_stab.emit(target))
	_add_prompt(prompt)


func add_someone_else_was_stabbed_prompt(stabber: Character, stabbee: Character) -> void:
	var prompt := PROMPT.instantiate() as Prompt
	prompt.someone_else_was_stabbed(stabber, stabbee)
	_add_prompt(prompt)


func _add_prompt(prompt: Prompt) -> void:
	prompt.self_character = current_character
	prompt.request_deletion.connect(func() -> void:
		prompts.erase(prompt)
		prompt.queue_free()
	)
	prompts.append(prompt)
	prompt.visible = false
	add_child(prompt)


func _view_neighbor_clue_color() -> void:
	var self_index := game_characters_list.get_children().find_custom(
		func(char_ui: CharacterRowUI) -> bool:
			return char_ui.character == current_character
	)
	if self_index == -1:
		push_error("Can't find current character in all_characters ui!")
	var neighbor_index := self_index - 1
	if neighbor_index < 0:
		neighbor_index = game_characters_list.get_children().size() - 1
	var neighbor_ui := game_characters_list.get_child(neighbor_index) as CharacterRowUI
	neighbor_ui.clue_color.visible = true


func _get_clan_color_image(clan: CharacterStats.Clan) -> Resource:
	match clan:
		CharacterStats.Clan.RED: return CLAN_RED_ICON
		CharacterStats.Clan.BLUE: return CLAN_BLUE_ICON
		CharacterStats.Clan.PURPLE: return CLAN_INQUISITOR_ICON
		_: push_error("Clan not associated with clan icon: %s" % clan)
	return


func _get_rank_icon(character: Character) -> Resource:
	match character.rank:
		CharacterStats.Rank.ELDER: return WOUND_RANK_1_ICON
		CharacterStats.Rank.ASSASSIN: return WOUND_RANK_2_ICON
		CharacterStats.Rank.HARLEQUIN: return WOUND_RANK_3_ICON
		CharacterStats.Rank.ALCHEMIST: return WOUND_RANK_4_ICON
		CharacterStats.Rank.MENTALIST: return WOUND_RANK_5_ICON
		CharacterStats.Rank.GUARDIAN: return WOUND_RANK_6_ICON
		CharacterStats.Rank.BERSERKER: return WOUND_RANK_7_ICON
		CharacterStats.Rank.MAGE: return WOUND_RANK_8_ICON
		CharacterStats.Rank.COURTESAN: return WOUND_RANK_9_ICON
		CharacterStats.Rank.INQUISITOR: return WOUND_RANKINQUISITOR_ICON
		_: push_error("Not a valid character rank: %s" % character.rank)
	return


func _get_alignment_wound_icon(wound: CharacterStats.Wound) -> Resource:
	match wound:
		CharacterStats.Wound.RED: return WOUND_RED_ICON
		CharacterStats.Wound.BLUE: return WOUND_BLUE_ICON
		CharacterStats.Wound.UNKNOWN: return WOUND_UNKNOWN_ICON
		CharacterStats.Wound.ANY: return WOUND_ANY_ICON
		_: push_error("Can't find alignment wound icon for wound type: %s" % wound)
	return
