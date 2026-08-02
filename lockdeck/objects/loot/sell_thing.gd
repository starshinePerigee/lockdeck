extends TextureButtonWithLabel

signal sell_clicked

func do_sell() -> void:
	sell_clicked.emit()

	if len(get_children()) <= 1:
		return
	$Loot.get_that_bag()
	
func _ready():
	pressed.connect(do_sell)
