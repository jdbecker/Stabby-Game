class_name InterventionPromptRow
extends HBoxContainer

@onready var name_label: Label = %NameLabel
@onready var accept_button: Button = %AcceptButton
@onready var offer_button: Button = %OfferButton
@onready var thinking_button: Button = %ThinkingButton
@onready var reject_button: Button = %RejectButton

var target_view := false
var character_name : String


func _ready() -> void:
	name_label.text = character_name
	if target_view:
		accept_button.visible = true
		offer_button.visible = false
		thinking_button.visible = true
		reject_button.visible = false
		accept_button.disabled = true
		offer_button.disabled = true
		thinking_button.disabled = true
		reject_button.disabled = true
	else:
		accept_button.visible = false
		offer_button.visible = true
		thinking_button.visible = true
		reject_button.visible = true
		offer_button.disabled = false
		thinking_button.disabled = false
		reject_button.disabled = false
	var button_group = ButtonGroup.new()
	offer_button.button_group = button_group
	thinking_button.button_group = button_group
	reject_button.button_group = button_group
	offer_button.toggled.connect(_offer_toggled)
	thinking_button.toggled.connect(_thinking_toggled)
	reject_button.toggled.connect(_reject_toggled)


func _offer_toggled(toggle_state: bool) -> void:
	accept_button.disabled = not toggle_state


func _thinking_toggled(toggle_state: bool) -> void:
	pass


func _reject_toggled(toggle_state: bool) -> void:
	pass
