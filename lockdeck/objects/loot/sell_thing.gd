extends TextureButtonWithLabel

signal sell_clicked

func do_sell() -> void:
	sell_clicked.emit()
	$DisplayCoin.claim_coin()

func reset() -> void:
	$DisplayCoin.reset()
	
func _ready():
	super._ready()
	pressed.connect(do_sell)
