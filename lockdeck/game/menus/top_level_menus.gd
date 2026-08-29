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

func _ready() -> void:
	$Title.new_game.connect(show_deck_select)
	$Title.credits.connect(show_credits)
	$Credits/ReturnButton.pressed.connect(credits_to_title)
	$DeckSelect/ReturnButton.pressed.connect(deck_select_to_title)
