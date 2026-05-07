@tool
extends Control

func update_card(i):
	var selection: String = $TemplateSelector.get_item_text(i)
	print("Selected %s" % selection)
	$PickCard.load_template(PickTemplateData.PickTemplateFlavors.get(selection))

func _ready():
	$TemplateSelector.clear()
	for f in PickTemplateData.PickTemplateFlavors:
		$TemplateSelector.add_item(f)
	$TemplateSelector.item_selected.connect(update_card)
