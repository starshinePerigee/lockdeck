extends VBoxContainer

func update(game: GameSpec):
	@warning_ignore("integer_division")
	%HeistLabel.text = "Heist %s" % game.get_heist()
	%MaxCountLabel.text = str(
		min(
			game.LOCK_SEQUENCE[game.lock_number + 1],
			5
		)
	)

func _ready() -> void:
	if get_tree().current_scene == self:
		var game := GameSpec.get_in_progress_game()
		update(game)
