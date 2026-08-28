class_name PlayerRow
extends PanelContainer

signal give_dagger_requested(character: Character)
signal add_wound_requested(character: Character, wound_type: CharacterStats.Wound)
signal remove_wound_requested(character: Character, wound_type: CharacterStats.Wound)
signal capture_requested(character: Character)
signal clear_wounds_requested(character: Character)

@onready var _give_dagger: Button = %GiveDagger
@onready var _info: Label = %Info
@onready var _wounds_label: Label = %Wounds
@onready var _wound_type: OptionButton = %WoundType
@onready var _add: Button = %Add
@onready var _remove: Button = %Remove
@onready var _capture: Button = %Capture
@onready var _clear: Button = %Clear

var _index: int
var _character: Character


func setup(index: int, character: Character) -> void:
	_index = index
	_character = character
	_give_dagger.pressed.connect(func() -> void: give_dagger_requested.emit(_character))
	_add.pressed.connect(func() -> void: add_wound_requested.emit(_character, _selected_wound()))
	_remove.pressed.connect(func() -> void: remove_wound_requested.emit(_character, _selected_wound()))
	_capture.pressed.connect(func() -> void: capture_requested.emit(_character))
	_clear.pressed.connect(func() -> void: clear_wounds_requested.emit(_character))
	_wound_type.item_selected.connect(func(_i: int) -> void: _refresh_wound_controls())
	refresh()


func _selected_wound() -> CharacterStats.Wound:
	return _wound_type.get_selected_id() as CharacterStats.Wound


func refresh(knife_holder: Character = null) -> void:
	var captured := _character.is_captured
	var suffix := "  [CAPTURED]" if captured else ""
	_info.text = "%s  %s  clue:%s%s" % [
		_character.name, str(_character), CharacterStats.Clan.keys()[_character.clue_color], suffix
	]
	_wounds_label.text = _character.wounds_to_string(_character.wounds)
	_give_dagger.text = "HOLDS" if _character == knife_holder else "give"
	_refresh_wound_controls()


func _refresh_wound_controls() -> void:
	var captured := _character.is_captured
	var wound := _selected_wound()
	var valid := _character.valid_new_wounds()
	_add.disabled = captured or wound not in valid
	_remove.disabled = wound not in _character.wounds
	_capture.disabled = captured or not valid.is_empty()
	_clear.disabled = _character.wound_count() == 0
