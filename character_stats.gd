class_name CharacterStats
extends Resource
## Static data for different character types

enum Clan {UNKNOWN, BLUE, RED, PURPLE}
enum Rank {INQUISITOR, ELDER, ASSASSIN, HARLEQUIN, ALCHEMIST, MENTALIST, GUARDIAN, BERSERKER, MAGE, COURTESAN}
enum Wound {UNKNOWN, BLUE, RED, RANK, ANY}

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
