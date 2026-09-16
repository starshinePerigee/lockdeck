extends Node2D

func update_pick(i: int) -> void:
	var selected: String = $TemplateSelector.get_item_text(i)
	for t in PickTemplates.ALL_PICKS:
		if t.pick_name == selected:
			print("Loaded pick %s" % t.pick_name)
			var spec := CardSpec.from_template(t)
			if t in PickTemplates.temporary_picks:
				spec.ability = Abilities.TEMPORARY
			
			$PickCard.card_spec = spec
			return
	push_error("Could not find pick from selector!")

func _ready() -> void:
	$PickCard.card_spec = CardSpec.from_template(PickTemplates.LOADING)
	for t in PickTemplates.ALL_PICKS:
		$TemplateSelector.add_item(t.pick_name)
	
	$TemplateSelector.item_selected.connect(update_pick)
