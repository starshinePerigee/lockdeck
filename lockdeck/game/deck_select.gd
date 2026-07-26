extends Control

signal start_game(cards: Array[CardSpec])
signal return_to_menu

var current_deck: DeckTemplates

func do_start() -> void:
	var specs: Array[CardSpec] = []
	specs.assign(current_deck.deck_gen.call())
	start_game.emit(specs)

func select_deck(template: DeckTemplates) -> void:
	current_deck = template
	$Panel/Info.text = template.description
	$Panel/Button.disabled = false
	$Panel/Button.text = "Sounds good, let's get started."

func reset() -> void:
	current_deck = null
	$Panel/Info.text = ""
	$Panel/Button.disabled = true
	$Panel/Button.text = "Select a deck."
	
func _ready() -> void:
	reset()
	
	# remove the placeholder buttons
	for child in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(child)
		child.queue_free()
	
	for deck_template in DeckTemplates.ALL_DECKS:
		var button := Button.new()
		button.text = deck_template.deck_name.capitalize()
		button.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(select_deck.bind(deck_template))
		$VBoxContainer.add_child(button)
	
	$Panel/Button.pressed.connect(do_start)
	$ReturnButton.pressed.connect(return_to_menu.emit)