extends Node2D

func u(i: int):
	var selected: String = $OptionButton.get_item_text(i)
	for t in PickTemplates.valid_templates:
		if t.pick_name == selected:
			$PickCard.card_spec = CardSpec.from_template(t)
			return

func _ready() -> void:
	PickTemplates.valid_templates.append(PickTemplates.DEBUG)
	for t in PickTemplates.valid_templates:
		$OptionButton.add_item(t.pick_name)
	$OptionButton.item_selected.connect(u)
