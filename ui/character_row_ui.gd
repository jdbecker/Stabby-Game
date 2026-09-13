class_name CharacterRowUI
extends VBoxContainer

var character: Character

const CLAN_BLUE_ICON = preload("uid://crs81muwa6whu")
const CLAN_RED_ICON = preload("uid://bufdewe0mkvel")

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

const WOUND_RED_ICON = preload("uid://da2qqjuydttxq")
const WOUND_BLUE_ICON = preload("uid://dgilhq7wk48f4")
const WOUND_UNKNOWN_ICON = preload("uid://bftmwicr7g3sm")

@onready var character_name: Label = %CharacterName
@onready var knife_icon: TextureRect = %KnifeIcon
@onready var clue_color: HBoxContainer = %ClueColor
@onready var clue_color_icon: TextureRect = %ClueColorIcon
@onready var rank_wound: TextureRect = %RankWound
@onready var character_h_box: HBoxContainer = %CharacterHBox
var affiliation_wounds : Array[TextureRect] = []


func _ready() -> void:
	if not character:
		push_error("Must supply a character before initializing CharacterRowUI!")
	character_name.text = character.name
	clue_color_icon.texture = _get_clue_icon(character)
	rank_wound.texture = _get_rank_icon(character)
	update()


func update() -> void:
	for wound in affiliation_wounds:
		wound.queue_free()
	knife_icon.visible = character.has_knife
	var has_taken_rank_wound := CharacterStats.Wound.RANK in character.wounds
	rank_wound.visible = has_taken_rank_wound
	var affiliation_wounds_taken := character.wounds.duplicate()
	affiliation_wounds_taken.erase(CharacterStats.Wound.RANK) # noop if not found
	for wound in affiliation_wounds_taken:
		var new_wound := TextureRect.new()
		affiliation_wounds.append(new_wound)
		new_wound.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		character_h_box.add_child(new_wound)
		match wound:
			CharacterStats.Wound.RED: new_wound.texture = WOUND_RED_ICON
			CharacterStats.Wound.BLUE: new_wound.texture = WOUND_BLUE_ICON
			CharacterStats.Wound.UNKNOWN: new_wound.texture = WOUND_UNKNOWN_ICON
			_: push_error("Can't add a wound icon for wound type: %s" % wound)


func _get_clue_icon(character: Character) -> Resource:
	match character.clue_color:
		CharacterStats.Clan.RED: return CLAN_RED_ICON
		CharacterStats.Clan.BLUE: return CLAN_BLUE_ICON
		_: push_error("Not a valid clue color: %s" % character.clue_color)
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
