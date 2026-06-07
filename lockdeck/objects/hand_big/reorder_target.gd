extends TextureRect

func set_selected(_area):
	visible = true

func set_deselected(_area):
	visible = false

func _ready():
	$ReorderArea.area_entered.connect(set_selected)
	$ReorderArea.area_exited.connect(set_deselected)
