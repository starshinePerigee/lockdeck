extends Control

signal start_game(cards: Array[CardSpec])
signal start_tutorial
signal return_to_menu

var current_deck: DeckTemplates

func do_start() -> void:
	if current_deck == DeckTemplates.TUTORIAL:
		start_tutorial.emit()
		return
	
	var specs: Array[CardSpec] = []
	specs.assign(current_deck.deck_gen.call())
	start_game.emit(specs)

# TODO: display deck button?

func select_deck(template: DeckTemplates) -> void:
	current_deck = template
	%Info.text = template.description
	%GoButton.disabled = false
	%GoButton.text = "sounds good, let's get started >"

func reset() -> void:
	current_deck = null
	%Info.text = ""
	%GoButton.disabled = true
	%GoButton.text = "Select a deck."

func _print_cards(cards: Array[CardSpec]):
	for card in cards:
		print(card.pick_name)

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
	
	%GoButton.pressed.connect(do_start)
	$ReturnButton.pressed.connect(return_to_menu.emit)
	
	if get_parent() == get_tree().root:
		start_game.connect(_print_cards) 