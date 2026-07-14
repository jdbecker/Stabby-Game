class_name DevPanel
extends Control

const PlayerRowScene := preload("res://ui/player_row.tscn")

@onready var _player_count: SpinBox = %PlayerCount
@onready var _new_game_button: Button = %NewGameButton
@onready var _summary: Label = %Summary
@onready var _player_list: VBoxContainer = %PlayerList

var game: Game


func _ready() -> void:
	_new_game_button.pressed.connect(_start_new_game)
	_start_new_game()


func _start_new_game() -> void:
	if game and game.state_changed.is_connected(_update_summary):
		game.state_changed.disconnect(_update_summary)
	for child in _player_list.get_children():
		child.queue_free()
	game = Game.new(int(_player_count.value))
	game.state_changed.connect(_update_summary)
	for i in game.characters.size():
		var row: PlayerRow = PlayerRowScene.instantiate()
		_player_list.add_child(row)
		row.setup(game, i, game.characters[i])
	_update_summary()


func _update_summary() -> void:
	var holder_index := game.characters.find(game.knife_holder)
	_summary.text = "Dagger: P%d %s    |    %d players" % [
		holder_index, str(game.knife_holder), game.characters.size()
	]
