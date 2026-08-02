extends Control
## This is the loot distribution scene

signal continue_to_next

func do_loot(value: int) -> void:
	$ContinueButton.disabled = true
	
	var pending_loots: Array[Loots] = LootGenerator.get_standard_loot_with_total_value(value)
	var real_loot: Array[Loot] = []
	
	for loots in pending_loots:
		var real := Loot.new_loot(loots)
		match loots.category:
			Loots.LootsTypes.COIN:
				real.loot_hovered.connect(real.get_that_bag)
			Loots.LootsTypes.BAR:
				real.loot_clicked.connect(real.get_that_bag)
		real_loot.append(real)
				
	$LootDrop.queue_loot(real_loot)

func _enable_continue() -> void:
	$ContinueButton.disabled = false

func _ready() -> void:
	$ContinueButton.pressed.connect(continue_to_next.emit)
	$LootDrop.all_looted.connect(_enable_continue)
	
	# if name == "__main__:
	if get_tree().current_scene == self:
		do_loot(100)
