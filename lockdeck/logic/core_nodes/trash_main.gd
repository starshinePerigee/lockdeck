extends Button
## Manages the trash pile

signal display_cards(Array)

@export var cards: Array[CardSpec]

func count() -> int:
	return len(cards)

func show_display() -> void:
	display_cards.emit(cards)
	
## Add a card to the trash
func add_card(card: CardSpec) -> void:
	cards.append(card)
	text = "Broken: %s" % len(cards)

func bump_label() -> void:
	update_label(count() + 1)

func update_label(n: int = -1) -> void:
	if n == -1:
		n = count()
	text = "Broken: %s" % n

## resets trashmain, emptying the trash
func reset() -> void:
	cards = []
	text = "Broken: 0"

func _ready() -> void:
	pressed.connect(show_display)
	reset()
