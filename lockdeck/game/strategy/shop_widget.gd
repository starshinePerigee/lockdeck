extends VBoxContainer
class_name ShopWidget

signal card_bought(card_spec: CardSpec)

var _coins := 0

func set_coins(coins: int) -> void:
	_coins = coins
	for button in %CardGrid.get_children():
		if button is MoneyButton:
			var buy_cost: int = button.card.get_buy_cost()
			button.disabled = buy_cost > _coins

func do_buy(button: MoneyButton) -> void:
	card_bought.emit(button.card)
	%CardGrid.remove_child(button)
	button.queue_free()
	%EmptyLabel.visible = %CardGrid.get_child_count() == 0

func load_inventory(new_cards: Array[CardSpec]) -> void:
	for child in %CardGrid.get_children():
		%CardGrid.remove_child(child)
		child.queue_free()
		
	for card in new_cards:
		var buy_cost := card.get_buy_cost()
		var card_button := MoneyButton.build_from_spec(
			card,
			"[ %s ]" % buy_cost
		)
		card_button.confirm_label = "Buy for %s g?" % buy_cost
		card_button.pressed_confirmed.connect(do_buy.bind(card_button))
		%CardGrid.add_child(card_button)
	
	%EmptyLabel.visible = false

func reset(game: GameSpec) -> void:
	set_coins(game.coins)

func _ready() -> void:
	if get_tree().current_scene == self:
		load_inventory(PickGenerator.get_many_base_cards(4))