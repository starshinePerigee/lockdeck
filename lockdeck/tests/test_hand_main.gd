extends Node2D

func draw_card() -> void:
	$HandMain.add_card(PickGenerator.get_random_base_card())

func discard_card() -> void:
	var i := int($DiscardEnter.text)
	var c: CardSpec = $HandMain.remove_card(i)
	print("Removed %s" % c.pick_name)

func load_cards() -> void:
	var n := int($ManyEnter.text)
	var new_cards: Array[CardSpec] = []
	for i in n:
		new_cards.append(PickGenerator.get_random_base_card())
	var c: Array[CardSpec] = $HandMain.load_new_hand(new_cards)
	print("Removed %s cards" % len(c))

func _ready() -> void:
	$DrawButton.pressed.connect(draw_card)
	$DiscardButton.pressed.connect(discard_card)
	$ManyButton.pressed.connect(load_cards)
