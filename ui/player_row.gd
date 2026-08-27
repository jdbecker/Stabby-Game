class_name PlayerRow
extends PanelContainer

@onready var _give_dagger: Button = %GiveDagger
@onready var _info: Label = %Info
@onready var _wounds_label: Label = %Wounds
@onready var _wound_type: OptionButton = %WoundType
@onready var _add: Button = %Add
@onready var _remove: Button = %Remove
@onready var _capture: Button = %Capture
@onready var _clear: Button = %Clear

var _game: Game
var _index: int
var _character: Character


func setup(game: Game, index: int, character: Character) -> void:
	_game = game
	_index = index
	_character = character
	_give_dagger.pressed.connect(func() -> void: _game.set_knife_holder(_character))
	_add.pressed.connect(func() -> void: _game.suffer_wound(_character, _selected_wound_context()))
	_remove.pressed.connect(func() -> void: _game.remove_wound(_character, _selected_wound()))
	_capture.pressed.connect(func() -> void: _game.capture(_character))
	_clear.pressed.connect(func() -> void: _game.clear_wounds(_character))
	_wound_type.item_selected.connect(func(_i: int) -> void: refresh())
	_game.state_changed.connect(refresh)
	refresh()


func _selected_wound() -> CharacterStats.Wound:
	return _wound_type.get_selected_id() as CharacterStats.Wound


func _selected_wound_context() -> WoundContext:
	var wound := WoundContext.new(_game.knife_holder)
	wound.wound_type = _wound_type.get_selected_id() as CharacterStats.Wound
	return wound


func refresh() -> void:
	var captured := _character.is_captured
	var suffix := "  [CAPTURED]" if captured else ""
	_info.text = "%s  %s  clue:%s%s" % [
		_character.name, str(_character), CharacterStats.Clan.keys()[_character.clue_color], suffix
	]
	_wounds_label.text = _character.wounds_to_string(_character.wounds)
	_give_dagger.text = "HOLDS" if _character == _game.knife_holder else "give"

	var wound := _selected_wound()
	var valid := _character.valid_new_wounds()
	_add.disabled = captured or wound not in valid
	_remove.disabled = wound not in _character.wounds
	_capture.disabled = captured or not valid.is_empty()
	_clear.disabled = _character.wound_count() == 0
