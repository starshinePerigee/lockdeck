extends VBoxContainer
class_name DeckWidget

signal card_sold(card_spec: CardSpec)

func do_sell(card: CardSpec):
	card_sold.emit(card)

func load_cards(cards: Array[CardSpec]) -> void:
	for child in %CardGrid.get_children():
		%CardGrid.remove_child(child)
		child.queue_free()
	
	for card in cards:
		var card_button := MoneyButton.build_from_spec(
			card,
			"",
			true
		)
		card_button.confirm_label = "Sell for 5 g?"
		card_button.pressed_confirmed.connect(do_sell.bind(card))
		%CardGrid.add_child(card_button)

func reset(game: GameSpec) -> void:
	load_cards(game.current_deck)
	$ScrollContainer.scroll_vertical = 0

func _ready() -> void:
	if get_tree().current_scene == self:
		var game := GameSpec.get_in_progress_game()
		load_cards(game.current_deck)
