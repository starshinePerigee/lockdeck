extends Control

signal continue_to_next

var _game: GameSpec

@onready var deck_widget: DeckWidget = $DeckPopover.get_inside_node()
@onready var repair_widget: RepairWidget = $RepairPopover.get_inside_node()
@onready var shop_widget: ShopWidget = $ShopPopover.get_inside_node()

const Y_OFFSET := 64 - 16
@onready var HIDDEN_Y: int = get_viewport().size.y + Y_OFFSET

var current_panel: Control

func set_game(game: GameSpec) -> void:
	_game = game
	update_info()

# This could be consolidated... but we're on the perimiter of this game, so nah

func do_buy(card: CardSpec) -> void:
	var buy_cost := card.get_buy_cost()
	if buy_cost > _game.coins:
		push_error(
			"Tried to buy card with cost %s and coins %s! Setting coins to 0."
			% [buy_cost, _game.coins]
		)
		_game.coins = 0
	else:
		_game.coins -= buy_cost
	_game.add_pick(card)
	shop_widget.set_coins(_game.coins)
	update_info()

func do_repair(card: CardSpec) -> void:
	var repair_cost := card.get_repair_cost()
	if repair_cost > _game.coins:
		push_error(
			"Tried to repair pick with cost %s and coins %s! Setting coins to 0."
			% [repair_cost, _game.coins]
		)
		_game.coins = 0
	else:
		_game.coins -= repair_cost
	_game.repair_pick(card)
	repair_widget.load_cards(_game.broken_picks)
	repair_widget.set_coins(_game.coins)
	update_info()

func do_repair_all() -> void:
	var repair_cost := 0
	for card in _game.broken_picks:
		repair_cost += card.get_repair_cost()
	if repair_cost >= _game.coins:
		push_error(
			"Tried to repair all with total cost %s and coins %s! Setting coins to 0."
			% [repair_cost, _game.coins]
		)
		_game.coins = 0
	
	# needed to avoid modifying array while in loop
	var picks_to_repair: Array[CardSpec] = _game.broken_picks.duplicate()
	for pick in picks_to_repair:
		_game.repair_pick(pick)
	
	repair_widget.load_cards(_game.broken_picks)
	repair_widget.set_coins(_game.coins)
	update_info()

func do_remove_forever(card: CardSpec) -> void:
	_game.remove_broken_pick_forever(card)
	repair_widget.load_cards(_game.broken_picks)
	update_info()

func do_sell(card: CardSpec) -> void:
	_game.remove_real_pick_forever(card)
	_game.add_coins(5)
	deck_widget.load_cards(_game.current_deck)
	update_info()

func show_panel(new_panel: StrategyPopover) -> void:
	if current_panel != null:
		var exit_tween := create_tween()
		exit_tween.set_trans(Tween.TRANS_CUBIC)
		exit_tween.tween_property(current_panel, "position:y", HIDDEN_Y, 0.4)
		exit_tween.tween_callback(current_panel.hide)
	
	if new_panel == current_panel:
		current_panel = null
	else:
		new_panel.show()
		new_panel.get_inside_node().reset(_game)
		var enter_tween := create_tween()
		if current_panel != null:
			enter_tween.tween_interval(0.2)
		enter_tween.set_trans(Tween.TRANS_CUBIC)
		enter_tween.tween_property(new_panel, "position:y", Y_OFFSET, 0.4)
		current_panel = new_panel

func update_info() -> void:
	$MetaInfo.redraw(_game)
	$EffectCount.update_counts(_game.current_deck)

func reset() -> void:
	update_info()
	
	for popover in [$DeckPopover, $RepairPopover, $ShopPopover]:
		popover.position.y = HIDDEN_Y
	current_panel = null
	
	shop_widget.load_inventory(PickGenerator.get_many_base_cards(4))

func _ready() -> void:
	$ContinueButton.pressed_confirmed.connect(continue_to_next.emit)
	$TabButtonBox/DeckButton.pressed.connect(show_panel.bind($DeckPopover))
	$TabButtonBox/RepairButton.pressed.connect(show_panel.bind($RepairPopover))
	$TabButtonBox/ShopButton.pressed.connect(show_panel.bind($ShopPopover))
	
	deck_widget.card_sold.connect(do_sell)
	repair_widget.repair_pick.connect(do_repair)
	repair_widget.remove_pick_forever.connect(do_remove_forever)
	repair_widget.repair_all.connect(do_repair_all)
	shop_widget.card_bought.connect(do_buy)
	
	if get_parent() == get_tree().root:
		_game = GameSpec.get_in_progress_game()
		reset()
