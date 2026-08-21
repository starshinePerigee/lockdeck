extends VBoxContainer

func update(game: GameSpec):
	@warning_ignore("integer_division")
	%HeistLabel.text = "Heist %s" % game.heist_number
	%MaxCountLabel.text = str(game.get_max_pin_count())

func _ready() -> void:
	if get_tree().current_scene == self:
		var game := GameSpec.get_in_progress_game()
		update(game)
