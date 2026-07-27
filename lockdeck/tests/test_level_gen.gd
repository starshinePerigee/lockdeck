extends Node2D

var _current_arc := LockGenerator.GameArcs.MID

func get_arc(idx: int) -> void:
	var selected: String = $ArcOption.get_item_text(idx)
	if selected in LockGenerator.GameArcs.keys():
		_current_arc = LockGenerator.GameArcs[selected]
	else:
		_current_arc = LockGenerator.GameArcs.EARLY
	print(_current_arc)

func print_deck() -> void:
	var deck := LockGenerator.get_base_template_deck(_current_arc)
	var total_hazard := 0
	for template in deck:
		print(template.depth.depth_name)
		total_hazard += template.net_hazard
	print("Count: %s" % len(deck))
	print("Total hazard: %s" % total_hazard)
	print("Hazard/template: %s" % (float(total_hazard) / len(deck)))

func get_lockset_deck() -> Array[DepthTemplates]:
	return LockGenerator.get_lockset_deck(
		_current_arc,
		int($HazardTarget.text),
		int($TemplateTarget.text)
	)

func print_lockset_deck() -> void:
	var pins := int($CountOption.value)
	var deck := get_lockset_deck()
	var total_depths := 0
	for template in deck:
		print(template.depth.depth_name)
		if template.depth != Depths.EMPTY:
			total_depths += template.total_depths_placed(pins)
	print(
		"Total depths to place: %s / %s" 
		% [total_depths, pins * 8]
	)

func _ready() -> void:
	$ArcOption.clear()
	for key in LockGenerator.GameArcs.keys():
		$ArcOption.add_item(key, LockGenerator.GameArcs[key])
	$ArcOption.select(1)
	$ArcOption.item_selected.connect(get_arc)
	
	$HazardTarget.text = "10"
	$TemplateTarget.text = "5"

	$BaseDeckButton.pressed.connect(print_deck)
	$LocksetDeckButton.pressed.connect(print_lockset_deck)
