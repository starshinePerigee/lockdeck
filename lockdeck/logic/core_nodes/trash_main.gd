extends Control
## Manages the trash pile

@export var cards: Array[CardSpec]

## Add a card to the trash
func add_card(card: CardSpec) -> void:
	cards.append(card)
	$Label.text = "Broken: %s" % len(cards)

func _ready() -> void:
	$Label.text = "Broken: 0"