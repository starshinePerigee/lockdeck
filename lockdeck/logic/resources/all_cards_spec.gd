extends Resource
## AllCardsSpec stores the state of all cards in the current playing field
class_name AllCardsSpec

@export var deck: Array[CardSpec]
@export var hand: Array[CardSpec]
@export var discard: Array[CardSpec]
@export var trash: Array[CardSpec]

func reify() -> void:
	for pile in [deck, hand, discard, trash]:
		for card in pile:
			card.reify()

func _init(
	deck_: Array[CardSpec] = [],
	hand_: Array[CardSpec] = [],
	discard_: Array[CardSpec] = [],
	trash_: Array[CardSpec] = [],
):
	deck = deck_
	
	if hand_:
		hand = hand_
	else:
		hand = []
	
	if discard_:
		discard = discard_
	else:
		discard = []
	
	if trash_:
		trash = trash_
	else:
		trash = []