extends VBoxContainer
class_name RepairWidget

signal repair_pick(CardSpec)

signal remove_pick_forever(CardSpec)

var _coins := 0

func set_coins(coins: int) -> void:
	_coins = coins
	for button in %CardGrid.get_children():
		if button is MoneyButton:
			button.disabled = button.card.get_repair_cost() > _coins

static var ALL_FONT_COLORS := [
	"font_color",
	"font_hover_color",
	"font_focused_color",
]

var remove_forever_mode := false:
	set(v):
		remove_forever_mode = v
		if remove_forever_mode:
			%ModeButton.text = "Removing broken picks forever"
			for override in ALL_FONT_COLORS:
				%ModeButton.add_theme_color_override(override, Color("bd4844"))
		else:
			%ModeButton.text = "Enable remove forever mode"
			for override in ALL_FONT_COLORS:
				%ModeButton.remove_theme_color_override(override)
		_set_button_removal(remove_forever_mode)

func _set_button_removal(removal: bool) -> void:
	for button in %CardGrid.get_children():
		if button is MoneyButton:
			button.removal = removal
			if removal:
				button.disabled = false
				button.label = ""
				button.confirm_label = "Remove forever?"
			else:
				button.label = "[ %s ]" % button.card.get_repair_cost()
				button.confirm_label = "Repair for %s?" % button.card.get_repair_cost()
	if not removal:
		set_coins(_coins)

func toggle_remove_forever() -> void:
	remove_forever_mode = not remove_forever_mode

func load_cards(cards: Array[CardSpec]) -> void:
	for child in %CardGrid.get_children():
		%CardGrid.remove_child(child)
		child.queue_free()
	
	for card in cards:
		var card_button := MoneyButton.build_from_spec(
			card,
			"[ %s ]" % card.get_repair_cost()
		)
		card_button.pressed_confirmed.connect(do_signal.bind(card))
		%CardGrid.add_child(card_button)
	set_coins(_coins)
	remove_forever_mode = remove_forever_mode

func do_signal(card: CardSpec) -> void:
	if remove_forever_mode:
		remove_pick_forever.emit(card)
	else:
		repair_pick.emit(card)

func reset(game: GameSpec) -> void:
	remove_forever_mode = false
	load_cards(game.broken_picks)
	set_coins(game.coins)
	$ScrollContainer.scroll_vertical = 0

func _ready() -> void:
	%ModeButton.pressed.connect(toggle_remove_forever)

	if get_tree().current_scene == self:
		var game := GameSpec.get_in_progress_game()
		load_cards(game.broken_picks)
		set_coins(game.coins)
