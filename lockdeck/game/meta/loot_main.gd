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

const FX_COIN_CLAIM := preload("res://assets/fx/coin_claim.ogg")
const FX_PICK_CLAIM := preload("res://assets/fx/pick_claim.ogg")

func do_coin(coin: Loot) -> void:
	coin.get_that_bag()
	game.add_coins(coin.spec.value)
	update_coin_count()
	if coin.fx_font == Loots.EffectFonts.CLACK:
		$LootDrop/ClickHeavyPlayer.play()
		$LootDrop/ChingHeavyPlayer.play()
	else:
		$LootDrop/ChingHeavyPlayer.play()
		$LootDrop/ChingHeavyPlayer.play()

func do_bar(bar: Loot) -> void:
	var widget := IngotWidget.unpack(bar.spec)
	widget.close_popup.connect($LootPopup.remove_and_close)
	widget.add_coins.connect(game.add_coins)
	widget.add_coins.connect(func(_x): GlobalEffects.request(FX_COIN_CLAIM))
	widget.add_pick.connect(game.add_pick)
	widget.add_pick.connect(func(_x): GlobalEffects.request(FX_PICK_CLAIM))
	$LootPopup.add_contents_and_show(widget, bar.spec)
	$LootPopup.visible = true
	bar.get_that_bag()
	$LootDrop/IngotHeavyPlayer.play()

func update_pick_count() -> void:
	$PickCount.text = "Picks: %s" % len(game.current_deck)

func update_coin_count() -> void:
	$CoinCount.text = "Coins: %s" % game.coins

var _already_claimed := false

func _enable_continue() -> void:
	if not _already_claimed:
		$ContinueButton.highlight = true

const VICTORY_MESSAGE := (
	"congradulations u won :v\n\ntotal coins: %s"
)

func claim_all() -> int:
	var claimed_loot: Array[Loots] = []
	for child in $LootDrop.get_children():
		if child is Loot:
			claimed_loot.append(child.spec)
			child.get_that_bag()
	for child in $LootDrop.loot_queue:
		claimed_loot.append(child.spec)
	$LootDrop.empty_queue()
	
	var loot_value := 0
	for loot in claimed_loot:
		if loot in Loots.ALL_COINS:
			loot_value += loot.value
		else:
			loot_value += 5
	return loot_value

func do_victory(count: int) -> void:
	reset()

	$CoinCount.visible = false
	$PickCount.visible = false
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
	$LootPopup.remove_and_close()
	$LootDrop.empty_queue()
	$LootDrop.clear_all()
	$VictoryLabel.visible = false
	_already_claimed = false
	$CoinCount.visible = true
	update_coin_count()
	$PickCount.visible = true
	update_pick_count()

const FX_ALL_COINS := preload("res://assets/fx/coins_many.ogg")
const FX_CLICK := preload("res://assets/fx/shell_click.ogg")

func claim_and_continue():
	_already_claimed = true
	var claimed := claim_all()
	game.add_coins(claimed)
	update_coin_count()
	var timer := create_tween()
	if claimed > 0:
		timer.tween_interval(0.5)
	GlobalEffects.request(FX_ALL_COINS)
	timer.tween_callback(continue_to_next.emit)

func get_nice_rect() -> Rect2:
	return $ContinueButton.get_global_rect().grow(4)

func request_continue_tooltip() -> void:
	if $ContinueButton.highlight:
		return
	TooltipManager.request_tooltip(
		get_nice_rect,
		(
			"Continue to your base.\n\n"
			+ "This will claim all unclaimed coins, and sell any unclaimed loot."
		)
	)

func _ready() -> void:
	$ContinueButton.pressed.connect(GlobalEffects.request.bind(FX_CLICK))
	$ContinueButton.pressed_confirmed.connect(claim_and_continue)
	$ContinueButton.mouse_entered.connect(request_continue_tooltip)
	$LootDrop.all_looted.connect(_enable_continue)
	$LootPopup.closed.connect(update_pick_count)
	$LootPopup.closed.connect(GlobalEffects.request.bind(FX_CLICK))
	
	# if name == "__main__:
	if get_tree().current_scene == self:
		game = GameSpec.get_in_progress_game()
		do_loot(200)
