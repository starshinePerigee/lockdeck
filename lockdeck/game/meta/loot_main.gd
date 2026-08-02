extends Control
## This is the loot distribution scene

signal continue_to_next

func do_loot() -> void:
	$ContinueButton.disabled = true
	
	var pending_loot: Array[Loots]
	pending_loot = LootGenerator.get_pile_with_value(100, LootGenerator.COIN_DECK)
	pending_loot.append_array(
		LootGenerator.get_pile_with_value(40, LootGenerator.BAR_DECK)
	)
	pending_loot.shuffle()
	for loot in pending_loot:
		var real: Loot = Loot.new_loot(loot)
		real.loot_hovered.connect(real.get_that_bag)
		var real_loots: Array[Loot] = [real]
		$LootDrop.queue_loot(real_loots)

func _enable_continue() -> void:
	$ContinueButton.disabled = false

func _ready() -> void:
	$ContinueButton.pressed.connect(continue_to_next.emit)
	$LootDrop.all_looted.connect(_enable_continue)
	
	# if name == "__main__:
	if get_tree().current_scene == self:
		do_loot()
