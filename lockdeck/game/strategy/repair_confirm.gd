extends Control

signal card_repaired(CardSpec)

var card: CardSpec:
	set(v):
		card = v
		%PickCard.card_spec = card


func _ready() -> void:
	if get_tree().current_scene == self:
		card = CardSpec.from_template(PickTemplates.DEBUG)
