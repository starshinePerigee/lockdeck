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
	for template in LockGenerator.get_base_template_deck(_current_arc):
		print(template.depth.depth_name)

func _ready() -> void:
	$ArcOption.clear()
	for key in LockGenerator.GameArcs.keys():
		$ArcOption.add_item(key, LockGenerator.GameArcs[key])
	$ArcOption.select(1)
	$ArcOption.item_selected.connect(get_arc)

	$BaseDeckButton.pressed.connect(print_deck)
