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

func _ready() -> void:
	pressed.connect(show_display)
	text = "Broken: 0"
