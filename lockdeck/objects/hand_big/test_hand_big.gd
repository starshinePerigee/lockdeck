extends Node2D

var cards: Array[CardSpec] = []

func card_selected(card_spec: CardSpec, card_index: int):
	print("Selected: %s" % cards[card_index])
	print("Should be %s" % card_spec)
	
func card_dropped(card_spec: CardSpec, card_area: Area2D, card_index: int):
	print("Dropped: %s" % card_index)
	
func card_deselected(card_index: int):
	print("Deselcted: %s" % card_index)

func _ready() -> void:
	for i in 5:
		cards.append(PickGenerator.get_random_base_card())
	$HandBig.cards = cards
	$HandBig.card_selected.connect(card_selected)
	$HandBig.card_dropped.connect(card_dropped)
	$HandBig.card_deselected.connect(card_deselected)
	$HandBig.redraw()
