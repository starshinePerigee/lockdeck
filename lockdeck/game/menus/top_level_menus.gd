extends Control
## This manages all the menus that happen before the game starts


func show_deck_select() -> void:
	$AnimationPlayer.play("go_deck_select")

func deck_select_to_title() -> void:
	$AnimationPlayer.play_backwards("go_deck_select")

func show_credits() -> void:
	$AnimationPlayer.play("go_credits")

func credits_to_title() -> void:
	$AnimationPlayer.play_backwards("go_credits")

func reset() -> void:
	$DeckSelect.reset()

const FX_SWIPE := preload("res://assets/fx/card_swipe_slide.ogg")
const FX_CLICK := preload("res://assets/fx/shell_click.ogg")

func _ready() -> void:
	$Title.new_game.connect(show_deck_select)
	$Title.credits.connect(show_credits)
	$Credits/ReturnButton.pressed.connect(credits_to_title)
	$DeckSelect/ReturnButton.pressed.connect(deck_select_to_title)
	
	var swipe_buttons := [
		$Title/NewGameButton, 
		$Title/CreditsButton, 
		$Credits/ReturnButton, 
		$DeckSelect/ReturnButton,
		$DeckSelect/GoButton
	]
	for swipe_button in swipe_buttons:
		swipe_button.pressed.connect(GlobalEffects.request.bind(FX_SWIPE))

	
	for child in get_children():
		for grandchild in child.get_children():
			if grandchild is BaseButton and grandchild not in swipe_buttons:
				grandchild.pressed.connect(GlobalEffects.request.bind(FX_CLICK))
			else:
				for great_grandchild in grandchild.get_children():
					if great_grandchild is BaseButton:
						great_grandchild.pressed.connect(GlobalEffects.request.bind(FX_CLICK))
