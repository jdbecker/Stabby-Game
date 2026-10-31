class_name Prompt
extends Control

signal request_deletion
signal stab_requested(stabbee: Character)
signal pass_knife_requested(recipient: Character)
signal intervention_accepted(intervener: Character)

const KNIFE_PROMPT_ROW = preload("uid://daprn3q5pgqys")
const INTERVENTION_PROMPT_ROW = preload("uid://dvdu55vtlxe7l")
const WOUND_PROMPT_ROW = preload("uid://dgkoag5ccp6ap")

var self_character: Character

@onready var prompt_body: MarginContainer = %PromptBody
@onready var show_hide_button: Button = %ShowHideButton
@onready var title_label: Label = %TitleLabel
@onready var details_label: Label = %DetailsLabel
@onready var confirm_button: Button = %ConfirmButton
@onready var prompt_elements: VBoxContainer = %PromptElements


func _ready() -> void:
	show_hide_button.pressed.connect(_toggle_visibility)
	confirm_button.pressed.connect(request_deletion.emit)


func knife_action(characters: Array[Character]) -> void:
	if not is_node_ready():
		await ready
	title_label.text = "You have the knife."
	details_label.text = "What would you like to do with it?"
	for character in characters:
		if character != self_character:
			var knife_prompt_row := KNIFE_PROMPT_ROW.instantiate() as KnifePromptRow
			knife_prompt_row.character = character
			knife_prompt_row.stab_requested.connect(func() -> void:
				request_deletion.emit()
				stab_requested.emit(character)
			)
			knife_prompt_row.pass_requested.connect(func() -> void:
				request_deletion.emit()
				pass_knife_requested.emit(character)
			)
			prompt_elements.add_child(knife_prompt_row)


func choose_intervener(attack_context: AttackContext) -> void:
	if not is_node_ready():
		await ready
	title_label.text = "%s is trying to stab you!" % attack_context.attacker.name
	details_label.text = "Will anyone intervene for you?"
	for character in attack_context.might_intervene:
		var intervention_prompt_row := INTERVENTION_PROMPT_ROW.instantiate() as InterventionPromptRow
		intervention_prompt_row.target_view = true
		intervention_prompt_row.character_name = character.name
		prompt_elements.add_child(intervention_prompt_row)
		intervention_prompt_row.accept_button.pressed.connect(func() -> void:
			request_deletion.emit()
			intervention_accepted.emit(character)
		)
	var hseparator := HSeparator.new()
	prompt_elements.add_child(hseparator)
	var cannot_intervene_label := Label.new()
	prompt_elements.add_child(cannot_intervene_label)
	cannot_intervene_label.text = "Cannot intervene"
	for character in attack_context.cant_intervene:
		var cant_intervene_character_label := Label.new()
		prompt_elements.add_child(cant_intervene_character_label)
		cant_intervene_character_label.text = character.name


func choose_wound(wound_context: WoundContext) -> void:
	if not is_node_ready():
		await ready
	title_label.text = "You've been stabbed!"
	details_label.text = "Choose a wound to take."
	for wound in self_character:
		var wound_prompt_row := WOUND_PROMPT_ROW.instantiate() as WoundPromptRow
		wound_prompt_row.wound_type = wound
		wound_prompt_row.character_rank = self_character.rank
		wound_prompt_row.selected.connect(func() -> void:
			wound_context.wound_type = wound
			self_character.take_wound(wound_context)
			request_deletion.emit()
		)
		prompt_elements.add_child(wound_prompt_row)


func someone_else_was_stabbed(stabber: Character, stabbee: Character) -> void:
	if not is_node_ready():
		await ready
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
