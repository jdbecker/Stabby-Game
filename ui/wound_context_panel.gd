class_name WoundContextPanel
extends PanelContainer

@onready var _attacker: Label = %Attacker
@onready var _intervened_for: Label = %IntervenedFor
@onready var _wound_type: Label = %WoundType
@onready var _block_ability: Label = %BlockAbility
@onready var _force_rank: Label = %ForceRank


func setup(wound_context: WoundContext) -> void:
	visible = wound_context != null
	if wound_context == null:
		return

	_attacker.text = "Attacker: %s" % _character_text(wound_context.attacker)
	_intervened_for.text = "Intervened for: %s" % _character_text(wound_context.intervened_for)
	_wound_type.text = "Wound type: %s" % _wound_type_text(wound_context.wound_type)
	_block_ability.text = "Block ability: %s" % wound_context.block_ability
	_force_rank.text = "Force rank: %s" % wound_context.force_rank


func _character_text(character: Character) -> String:
	return "None" if character == null else str(character)


func _wound_type_text(wound_type: CharacterStats.Wound) -> String:
	var wound_names := CharacterStats.Wound.keys()
	var wound_index := int(wound_type)
	return wound_names[wound_index] if wound_index >= 0 and wound_index < wound_names.size() else "Invalid"
