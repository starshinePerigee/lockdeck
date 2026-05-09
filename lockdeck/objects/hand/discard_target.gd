extends TextureRect

signal discard_entered
signal discard_exited

const DISCARD_DESELCTED = preload("res://assets/hand/discard_deselected.png")
const DISCARD_SELECTED = preload("res://assets/hand/discard_selected.png")

func set_selected(_area):
	texture = DISCARD_SELECTED
	discard_entered.emit()

func set_deselected(_area):
	texture=DISCARD_DESELCTED
	discard_exited.emit()

func _ready():
	$DiscardArea.area_entered.connect(set_selected)
	$DiscardArea.area_exited.connect(set_deselected)
