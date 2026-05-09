extends TextureRect

const REORDER_DESELECTED = preload("res://assets/hand/insertion_deselected.png")
const REORDER_SELECTED = preload("res://assets/hand/insertion_selected.png")

func set_selected(_area):
	texture = REORDER_SELECTED

func set_deselected(_area):
	texture=REORDER_DESELECTED

func _ready():
	$ReorderArea.area_entered.connect(set_selected)
	$ReorderArea.area_exited.connect(set_deselected)
