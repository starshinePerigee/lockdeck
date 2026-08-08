extends Control

signal continue_to_next

var _game: GameSpec

func update_info() -> void:
	$MetaInfo.redraw(_game)

func _ready() -> void:
	$ContinueButton.pressed_confirmed.connect(continue_to_next.emit)
	
	if get_parent() == get_tree().root:
		_game = GameSpec.get_in_progress_game()
		update_info()
