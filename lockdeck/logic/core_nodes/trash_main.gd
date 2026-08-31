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

func get_nice_rect() -> Rect2:
	return get_global_rect().grow(4)

func request_tooltip() -> void:
	TooltipManager.request_tooltip(
		get_nice_rect,
		(
			"This is your trash.\n\n"
			+ "Broken picks end up here. Once broken, picks are removed from your deck "
			+ "and must be repaired to be used again. \n\n"
			+ "Click this button to see all picks currently in your trash."
		)
	)

func _ready() -> void:
	mouse_entered.connect(request_tooltip)
	pressed.connect(show_display)
	reset()
