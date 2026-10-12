extends Control

signal start_game(cards: Array[CardSpec])
signal tutorial_start(int)
signal show_level_select
signal return_to_menu

var current_deck: DeckTemplates

func do_start() -> void:
	if current_deck == DeckTemplates.TUTORIAL:
		if MetaProgression.instance().tutorial_level > 0:
			show_level_select.emit()
		else:
			tutorial_start.emit(0)
		return
	
	var specs: Array[CardSpec] = []
	specs.assign(current_deck.deck_gen.call())
	start_game.emit(specs)

# TODO: display deck button?

func select_deck(template: DeckTemplates) -> void:
	current_deck = template
	%Info.text = template.description
	%GoButton.visible = true
	%GoButton.text = "sounds good, let's get started >"

func reset() -> void:
	current_deck = null
	
	var deck_unlock := MetaProgression.instance().deck_unlock_level
	for i in $VBoxContainer.get_child_count():
		$VBoxContainer.get_child(i).disabled = i > deck_unlock
	$UnlockGuide.visible = deck_unlock < 5
	
	%Info.text = "Select a deck."
	%GoButton.visible = false

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