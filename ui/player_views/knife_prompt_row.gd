class_name KnifePromptRow
extends HBoxContainer

signal pass_requested
signal stab_requested

var character: Character

@onready var player_name_label: Label = %PlayerNameLabel
@onready var pass_button: Button = %PassButton
@onready var stab_button: Button = %StabButton


func _ready() -> void:
	player_name_label.text = character.name
	pass_button.pressed.connect(pass_requested.emit)
	stab_button.pressed.connect(stab_requested.emit)
	if character.is_protected:
		stab_button.disabled
