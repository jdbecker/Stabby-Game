class_name CharacterStats
extends Resource
## Static data for different character types

enum Clan {UNKNOWN, BLUE, RED, PURPLE}
enum Rank {INQUISITOR, ELDER, ASSASSIN, HARLEQUIN, ALCHEMIST, MENTALIST, GUARDIAN, BERSERKER, MAGE, COURTESAN}
enum Wound {UNKNOWN, BLUE, RED, RANK, ANY}

const WOUND_BLUE_ICON = preload("uid://dgilhq7wk48f4")
const WOUND_RED_ICON = preload("uid://da2qqjuydttxq")
const WOUND_UNKNOWN_ICON = preload("uid://bftmwicr7g3sm")
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

@export var rank: Rank
@export var clan: Clan
var wounds: Array[Wound] : get = _get_wounds
var ability_description: String : get = _get_ability_description


func get_clue_color() -> Clan:
	match rank:
		Rank.INQUISITOR: return [Clan.BLUE, Clan.RED].pick_random()
		Rank.HARLEQUIN:
			match clan:
				Clan.BLUE: return Clan.RED
				Clan.RED: return Clan.BLUE
				_: push_error("Invalid CharacterStats! Harlequin must have a clan either Red or Blue!")
	return clan


func _get_wounds() -> Array[Wound]:
	match rank:
		Rank.INQUISITOR: return [Wound.RANK, Wound.ANY, Wound.ANY]
		Rank.ELDER: return [Wound.RANK, _get_clan_wound(), _get_clan_wound()]
		Rank.ASSASSIN: return [Wound.RANK, Wound.UNKNOWN, Wound.UNKNOWN]
		Rank.HARLEQUIN: return [Wound.RANK, Wound.UNKNOWN, Wound.UNKNOWN]
		Rank.ALCHEMIST: return [Wound.RANK, Wound.UNKNOWN, Wound.UNKNOWN]
		Rank.MENTALIST: return [Wound.RANK, _get_clan_wound(), _get_clan_wound()]
		Rank.GUARDIAN: return [Wound.RANK, _get_clan_wound(), _get_clan_wound()]
		Rank.BERSERKER: return [Wound.RANK, _get_clan_wound(), Wound.UNKNOWN]
		Rank.MAGE: return [Wound.RANK, _get_clan_wound(), Wound.UNKNOWN]
		Rank.COURTESAN: return [Wound.RANK, _get_clan_wound(), Wound.UNKNOWN]
		_: push_error("Unrecognized Rank: %s. Can't make valid wounds array!" % rank)
	return []


func _get_clan_wound() -> Wound:
	match clan:
		Clan.BLUE: return Wound.BLUE
		Clan.RED: return Wound.RED
		_: push_error("Cannot convert Clan: %s to a wound type!" % clan)
	return Wound.UNKNOWN


func _get_ability_description() -> String:
	match rank:
		Rank.INQUISITOR: return "You may attempt to predict the leader of the clan who will win. If you are right, you win instead! (Also, you have no allies, but you can take any color wounds.)"
		Rank.ELDER: return "You may play a [color=dark_blue]Quill[/color] for your clan. (While a clan has a [color=dark_blue]Quill[/color], the player with the highest rank - rather than the lowest - is their Leader.)"
		Rank.ASSASSIN: return "You may force any player to suffer 2 [color=dark_red]Wounds[/color]. If you do, give that player the dagger."
		Rank.HARLEQUIN: return "You may view any two players character cards. (Also, your clue color matches the enemy clan's color.)"
		Rank.ALCHEMIST: return "(Only used if you intervened) You may force the player for whom you intervened to suffer or heal 1 [color=dark_red]Wound[/color]."
		Rank.MENTALIST: return "You may force another player to suffer their rank token as a [color=dark_red]Wound[/color]. If you do, give that player the dagger."
		Rank.GUARDIAN: return "You may give a [color=dark_blue]Shield[/color] to another player and take a [color=dark_blue]Sword[/color] for yourself. (Players with a [color=dark_blue]Shield[/color] cannot suffer wounds until the player with a matching [color=dark_blue]Sword[/color] has 3 [color=dark_red]Wounds[/color].)"
		Rank.BERSERKER: return "You may force the player who attacked you to suffer 1 [color=dark_red]Wound[/color]."
		Rank.MAGE: return "You may give a [color=dark_blue]Staff[/color] to any other player and take a [color=dark_blue]Staff[/color] for yourself. (Players with a [color=dark_blue]Staff[/color] can only take \"?\" wounds or their rank token.)"
		Rank.COURTESAN: return "You may give a [color=dark_blue]Fan[/color] to a player. (Players cannot intervene for players with a [color=dark_blue]Fan[/color].)"
		_: push_error("Ability description not available for Rank: %s" % rank)
	return ""


static func get_affiliation_image(wound_type: Wound) -> Resource:
	match wound_type:
		Wound.UNKNOWN: return WOUND_UNKNOWN_ICON
		Wound.RED: return WOUND_RED_ICON
		Wound.BLUE: return WOUND_BLUE_ICON
		Wound.RANK: push_error("Use _get_rank_image for rank wounds!")
		_: push_error("Wound type %s doesn't have an image" % wound_type)
	return


static func get_rank_image(rank_type: Rank) -> Resource:
	match rank_type:
		Rank.ELDER: return WOUND_RANK_1_ICON
		Rank.ASSASSIN: return WOUND_RANK_2_ICON
		Rank.HARLEQUIN: return WOUND_RANK_3_ICON
		Rank.ALCHEMIST: return WOUND_RANK_4_ICON
		Rank.MENTALIST: return WOUND_RANK_5_ICON
		Rank.GUARDIAN: return WOUND_RANK_6_ICON
		Rank.BERSERKER: return WOUND_RANK_7_ICON
		Rank.MAGE: return WOUND_RANK_8_ICON
		Rank.COURTESAN: return WOUND_RANK_9_ICON
		Rank.INQUISITOR: return WOUND_RANKINQUISITOR_ICON
		_: push_error("Rank type %s doesn't have an image" % rank_type)
	return
