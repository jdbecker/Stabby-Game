class_name AbilityCard
extends RefCounted

var name: String
var description: String
var color := Color.WHITE


class Quill:
	extends AbilityCard
	func _init() -> void:
		name = "Quill"
		description = "The player from your clan with the highest number is now your clan's leader."


class Sword:
	extends AbilityCard
	func _init(new_color: Color) -> void:
		name = "Sword"
		description = "Until you suffer your third wound, you are protecting any player who has a matching color \"Shield.\""
		color = new_color


class Shield:
	extends AbilityCard
	func _init(new_color: Color) -> void:
		name = "Shield"
		description = "Until the player protecting you suffers their third wound, players cannot attack you or force you to suffer wounds, but you may intervene."
		color = new_color


class Staff:
	extends AbilityCard
	func _init() -> void:
		name = "Staff"
		description = "When you take an affiliation token, you must take an unknown affiliation token."


class Fan:
	extends AbilityCard
	func _init() -> void:
		name = "Fan"
		description = "When a player attacks you, other players cannot intervene."


class TrueCurse:
	extends AbilityCard
	func _init() -> void:
		name = "True Curse"
		description = "If the victorious clan's leader has this card at the end of the game, the Inquisitor wins."


class FalseCurse:
	extends AbilityCard
	func _init() -> void:
		name = "False Curse"
		description = "This card is a decoy and has no effect."
