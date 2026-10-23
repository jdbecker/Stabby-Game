class_name DevPanel
extends Control

signal pass_knife_requested(character: Character)
signal add_wound_requested(character: Character, wound_type: CharacterStats.Wound)
signal remove_wound_requested(character: Character, wound_type: CharacterStats.Wound)
signal capture_requested(character: Character)
signal clear_wounds_requested(character: Character)
signal new_game_requested(player_count: int)

const PLAYER_ROW = preload("uid://kq181b23yokv")
const PLAYER_VIEW = preload("uid://87n3mryosmpd")


@onready var _player_count: SpinBox = %PlayerCount
@onready var _new_game_button: Button = %NewGameButton
@onready var _summary: Label = %Summary
@onready var _player_list: VBoxContainer = %PlayerList

var _characters: Array[Character]
var _views: Array[PlayerView]


func _ready() -> void:
	_new_game_button.pressed.connect(func() -> void: new_game_requested.emit(int(_player_count.value)))


func _start_new_game() -> void:
	for child in _player_list.get_children():
		child.queue_free()
	_views.clear()

	# Game owns gameplay state; the panel only rebuilds its presentation.
	for i in _characters.size():
		var character := _characters[i]
		var view := PLAYER_VIEW.instantiate() as PlayerView
		view.current_character = character
		view.all_characters = _characters
		add_child(view)
		view.hide()
		_views.append(view)
		
		view.pass_knife_requested.connect(pass_knife_requested.emit)
		
		var row: PlayerRow = PLAYER_ROW.instantiate()
		_player_list.add_child(row)
		row.setup(i, character)
		row.pass_knife_requested.connect(pass_knife_requested.emit)
		row.add_wound_requested.connect(add_wound_requested.emit)
		row.remove_wound_requested.connect(remove_wound_requested.emit)
		row.capture_requested.connect(capture_requested.emit)
		row.clear_wounds_requested.connect(clear_wounds_requested.emit)
		row.view_requested.connect(func(_character) -> void: view.visible = true)
	update_state()


func setup(characters: Array[Character]) -> void:
	_characters = characters
	_start_new_game()


func update_state() -> void:
	for row: PlayerRow in _player_list.get_children():
		row.refresh()
	var knife_holders := _characters.filter(func(c: Character) -> bool: return c.has_knife)
	if not knife_holders:
		return # game state not yet done initializing
	var knife_holder := knife_holders.front() as Character
	_summary.text = "Dagger: %s %s    |    %d players" % [
		knife_holder.name, knife_holder, _characters.size()
	]
	for view: PlayerView in _views:
		view.refresh()
