class_name WoundPromptRow
extends Control

signal selected

const WOUND_UNKNOWN_ICON = preload("uid://bftmwicr7g3sm")
const WOUND_BLUE_ICON = preload("uid://dgilhq7wk48f4")
const WOUND_RED_ICON = preload("uid://da2qqjuydttxq")
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

var wound_type: CharacterStats.Wound
var character_rank: CharacterStats.Rank

@onready var _wound_image: TextureRect = %WoundImage
@onready var _select_button: Button = %SelectButton


func _ready() -> void:
	if wound_type == CharacterStats.Wound.RANK:
		_wound_image.texture = CharacterStats.get_rank_image(character_rank)
	else:
		_wound_image.texture = CharacterStats.get_affiliation_image(wound_type)
	_select_button.pressed.connect(selected.emit)
