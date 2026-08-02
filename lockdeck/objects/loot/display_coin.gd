extends Control

@onready var _coin: Loot = $Loot
@onready var _coin_pos: Vector2 = $Loot.position

var _has_coin: bool = true

func claim_coin() -> void:
	if not _has_coin:
		push_warning("Tried to claim coin without coin being present!")
		return
	_coin.get_that_bag()
	_coin = null
	_has_coin = false

func reset() -> void:
	if _has_coin:
		return
	
	_coin = Loot.new_loot(Loots.COIN_5)
	_coin.disable_physics()
	add_child(_coin)
	_coin.position = _coin_pos
	_has_coin = true

func _demo() -> void:
	if randi() % 2 == 0:
		print("tails")
		claim_coin()
	else:
		print("heads")
		reset()

func _ready() -> void:
	$Loot.disable_physics()
	
	# if name == "__main__:
	if get_tree().current_scene == self:
		mouse_entered.connect(_demo)