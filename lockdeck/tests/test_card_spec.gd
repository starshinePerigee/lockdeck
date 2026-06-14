extends Node2D

func update_pick(i: int) -> void:
	var selected: String = $TemplateSelector.get_item_text(i)
	for t in PickTemplates.valid_templates:
		if t.pick_name == selected:
			print("Loaded pick %s" % t.pick_name)
			$PickCard.card_spec = CardSpec.from_template(t)
			return
	push_error("Could not find pick from selector!")

func _ready() -> void:
	PickTemplates.valid_templates.append(PickTemplates.DEBUG)
	for t in PickTemplates.valid_templates:
		$TemplateSelector.add_item(t.pick_name)
	$TemplateSelector.item_selected.connect(update_pick)
