extends ScrollContainer

func load_cards(cards: Array[CardSpec]) -> void:
	for card in cards:
		var card_button := CardButton.build_from_spec(card)
		%CardGrid.add_child(card_button)

func _ready() -> void:
	load_cards(GameSpec.get_in_progress_game().broken_picks)