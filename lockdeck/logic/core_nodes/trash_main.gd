extends Button
## Manages the trash pile

signal display_cards(Array)

@export var cards: Array[CardSpec]

func show_display() -> void:
	display_cards.emit(cards)
	
## Add a card to the trash
func add_card(card: CardSpec) -> void:
	cards.append(card)
	text = "Broken: %s" % len(cards)

## resets trashmain, emptying the trash
func reset() -> void:
	cards = []
	text = "Broken: 0"

func _ready() -> void:
	pressed.connect(show_display)
	reset()
