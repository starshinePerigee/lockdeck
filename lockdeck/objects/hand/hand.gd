@tool
extends Control

signal card_discarded(card_index: int)
signal card_rearranged(card_index: int, new_position: int)

func show_areas():
	$DragIcons.visible = true
	$DiscardTarget.visible = true

func check_drop(area: Area2D, source_index: int):
	$DragIcons.visible = false
	$DiscardTarget.visible = false
	var collisions = area.get_overlapping_areas()
	if $DiscardTarget/DiscardArea in collisions:
		card_discarded.emit(source_index)
		return
	for i in range(len(reorder_areas)):
		if reorder_areas[i] in collisions:
			card_rearranged.emit(source_index, i)
			return

@export var card_specs: Dictionary[int, CardSpec] = {}:
	set(v):
		card_specs = v
		
		if not is_node_ready():
			await ready
		
		for i in range(len(space_refs)):
			if i in card_specs:
				space_refs[i].card_spec = card_specs[i]
				space_refs[i].has_card = true
			else:
				space_refs[i].has_card = false

var space_refs: Array[DragCard] = []
var reorder_areas: Array[Area2D] = []

func _ready():
	space_refs = [
		$Holder/Space1/DragCard1,
		$Holder/Space2/DragCard2,
		$Holder/Space3/DragCard3
	]
	for i in range(len(space_refs)):
		var bound_drop = check_drop.bind(i)
		space_refs[i].dropped.connect(bound_drop)
		space_refs[i].picked_up.connect(show_areas)
		
	# there has to be a better way than this but fuck it's friday
	reorder_areas = [
		$DragIcons/ReorderTarget0/ReorderArea,
		$DragIcons/ReorderTarget1/ReorderArea,
		$DragIcons/ReorderTarget2/ReorderArea,
		$DragIcons/ReorderTarget3/ReorderArea,
	]
