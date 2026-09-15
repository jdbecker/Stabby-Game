class_name Prompt
extends Control

signal request_deletion
signal request_stab(stabbee: Character)
signal request_pass_knife(recipient: Character)

const KNIFE_PROMPT_ROW = preload("uid://daprn3q5pgqys")

var self_character: Character

@onready var prompt_body: MarginContainer = %PromptBody
@onready var show_hide_button: Button = %ShowHideButton
@onready var title_label: Label = %TitleLabel
@onready var details_label: Label = %DetailsLabel
@onready var confirm_button: Button = %ConfirmButton
@onready var prompt_elements: VBoxContainer = %PromptElements


func _ready() -> void:
	show_hide_button.pressed.connect(_toggle_visibility)
	confirm_button.pressed.emit(request_deletion)


func knife_action(characters: Array[Character]) -> void:
	title_label.text = "You have the knife."
	details_label.text = "What would you like to do with it?"
	for character in characters:
		if character != self_character:
			var knife_prompt_row := KNIFE_PROMPT_ROW.instantiate() as KnifePromptRow
			knife_prompt_row.character = character
			knife_prompt_row.stab_requested.connect(func() -> void:
				request_deletion.emit()
				request_stab.emit(character)
			)
			knife_prompt_row.pass_requested.connect(func() -> void: 
				request_deletion.emit()
				request_pass_knife.emit(character)
			)
			prompt_elements.add_child(knife_prompt_row)


func someone_else_was_stabbed(stabber: Character, stabbee: Character) -> void:
	title_label.text = "%s stabbed %s." % [stabber.name, stabbee.name]
	details_label.text = "%s took a %s wound." % [stabbee.name, stabbee.last_wound]
	confirm_button.visible = true


func _toggle_visibility() -> void:
	if prompt_body.visible:
		prompt_body.visible = false
		show_hide_button.text = "🔔Show Prompt🔔"
	else:
		prompt_body.visible = true
		show_hide_button.text = "Hide"
