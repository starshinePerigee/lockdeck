extends Control
## This is the loot distribution scene

signal continue_to_next

var game: GameSpec

func drop_loot() -> void:
	$LootDrop.drop_loot()

func do_loot(value: int) -> void:
	reset()
	var pending_loots: Array[Loots] = LootGenerator.get_standard_loot_with_total_value(value)
	var real_loot: Array[Loot] = []
	
	for loots in pending_loots:
		var real := Loot.new_loot(loots)
		match loots.category:
			Loots.LootsTypes.COIN:
				real.loot_hovered.connect(do_coin.bind(real))
			Loots.LootsTypes.BAR:
				real.loot_clicked.connect(do_bar.bind(real))
		real_loot.append(real)
				
	$LootDrop.queue_loot(real_loot)

func do_coin(coin: Loot) -> void:
	coin.get_that_bag()
	game.add_coins(coin.spec.value)

func do_bar(bar: Loot) -> void:
	var widget := IngotWidget.unpack(bar.spec)
	widget.close_popup.connect(bar.get_that_bag)
	widget.close_popup.connect($LootPopup.remove_and_close)
	widget.add_coins.connect(game.add_coins)
	widget.add_pick.connect(game.add_pick)
	$LootPopup.add_contents_and_show(widget, bar.spec)
	$LootPopup.visible = true

func _enable_continue() -> void:
	$ContinueButton.disabled = false

const VICTORY_MESSAGE := (
	"congradulations u won :v\n\ntotal coins: %s"
)

func do_victory(count: int) -> void:
	reset()
	_enable_continue()
	$VictoryLabel.visible = true
	$VictoryLabel.text = VICTORY_MESSAGE % count
	
	var pending_loots := LootGenerator.get_standard_loot_with_total_value(5000)
	var real_loot: Array[Loot] = []
	
	for loots in pending_loots:
		var real := Loot.new_loot(loots)
		real.loot_hovered.connect(real.get_that_bag)
		real_loot.append(real)
	
	$LootDrop.queue_loot(real_loot)

func reset() -> void:
	$ContinueButton.disabled = true
	$LootPopup.remove_and_close()
	$LootDrop.empty_queue()
	$LootDrop.clear_all()

func _ready() -> void:
	$ContinueButton.pressed.connect(continue_to_next.emit)
	$LootDrop.all_looted.connect(_enable_continue)
	
	# if name == "__main__:
	if get_tree().current_scene == self:
		game = GameSpec.get_in_progress_game()
		do_loot(100)
