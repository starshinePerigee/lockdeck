extends Control
## This manages all the menus that happen before the game starts


func show_deck_select() -> void:
	$AnimationPlayer.play("go_deck_select")

func deck_select_to_title() -> void:
	$AnimationPlayer.play_backwards("go_deck_select")

func _ready() -> void:
	$Title.start_game.connect(show_deck_select)
	$DeckSelect/ReturnButton.pressed.connect(deck_select_to_title)
