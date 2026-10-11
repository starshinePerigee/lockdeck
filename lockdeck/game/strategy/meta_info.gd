extends VBoxContainer

func redraw(game: GameSpec) -> void:
	$CoinsLabel.text = "Coins: %s" % game.coins
	$BrokenLabel.text = "Broken: %s" % len(game.broken_picks)
	$PickLabel.text = "Picks: %s/20" % len(game.current_deck)
	if len(game.current_deck) > 20:
		$PickLabel.add_theme_color_override("font_color", Color("f1504b"))
	else:
		$PickLabel.remove_theme_color_override("font_color")
