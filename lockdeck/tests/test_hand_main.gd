extends Node2D

func select(card: CardSpec) -> void:
	print("Selected %s" % card.pick_name)

func deselect() -> void:
	print("Deselected")

func pick_up(card_area: Area2D, _card: CardSpec) -> void:
	for target: CardSpace in [$DropTarget1, $DropTarget2]:
		var area: Area2D = target.get_area()
		area.area_entered.connect(target.set_highlight.unbind(1))
		area.area_exited.connect(target.clear_highlight.unbind(1))

func drop(card_area: Area2D, card: CardSpec) -> void:
	var collisions := card_area.get_overlapping_areas()
	if $DropTarget1.get_area() in collisions:
		print("%s dropped on 1" % card.pick_name)
	if $DropTarget2.get_area() in collisions:
		print("%s dropped on 2" % card.pick_name)

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
	$HandMain.hand_selected.connect(select)
	$HandMain.hand_deselected.connect(deselect)
	$HandMain.hand_dragged.connect(pick_up)
	$HandMain.hand_dropped.connect(drop)
	
	draw_card()
	draw_card()
	draw_card()
