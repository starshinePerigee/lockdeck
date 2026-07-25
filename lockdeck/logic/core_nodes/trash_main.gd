extends Control
## Manages the trash pile

signal display_opened()

@export var cards: Array[CardSpec]

var _is_hovered := false

func set_hovered(hovered: bool) -> void:
	_is_hovered = hovered
	_draw_label()

@export var button_disable: bool = false:
	set(v):
		button_disable = v
		_draw_label()

func _draw_label() -> void:
	var font_color := Color("#ffffff")
	if button_disable:
		font_color = Color("#918891")
	elif _is_hovered:
		font_color = Color("#ffbc57")
	
	$Label.add_theme_color_override("font_color", font_color)

func show_display() -> void:
		$CardDisplay.show_display()
		display_opened.emit()

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not button_disable:
				show_display()

## Add a card to the trash
func add_card(card: CardSpec) -> void:
	cards.append(card)
	$Label.text = "Broken: %s" % len(cards)
	$CardDisplay.cards = cards

func _ready() -> void:
	gui_input.connect(_handle_input)
	mouse_entered.connect(set_hovered.bind(true))
	mouse_exited.connect(set_hovered.bind(false))

	$Label.text = "Broken: 0"
