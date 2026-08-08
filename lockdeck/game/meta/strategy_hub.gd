extends Control

signal continue_to_next

var _game: GameSpec

const Y_OFFSET := 64
@onready var HIDDEN_Y: int = get_viewport().size.y + Y_OFFSET
 
var current_panel: Control

func show_panel(new_panel: Control) -> void:
	if current_panel != null:
		var exit_tween := create_tween()
		exit_tween.set_trans(Tween.TRANS_CUBIC)
		exit_tween.tween_property(current_panel, "position:y", HIDDEN_Y, 0.4)
		exit_tween.tween_callback(current_panel.hide)
	
	if new_panel == current_panel:
		current_panel = null
	else:
		new_panel.show()
		var enter_tween := create_tween()
		if current_panel != null:
			enter_tween.tween_interval(0.2)
		enter_tween.set_trans(Tween.TRANS_CUBIC)
		enter_tween.tween_property(new_panel, "position:y", Y_OFFSET, 0.4)
		current_panel = new_panel

func update_info() -> void:
	$MetaInfo.redraw(_game)
	$EffectCount.update_counts(_game.current_deck)

func reset() -> void:
	for popover in [$DeckPopover, $RepairPopover, $ShopPopover]:
		popover.position.y = HIDDEN_Y
	current_panel = null

func _ready() -> void:
	$ContinueButton.pressed_confirmed.connect(continue_to_next.emit)
	$TabButtonBox/DeckButton.pressed.connect(show_panel.bind($DeckPopover))
	$TabButtonBox/RepairButton.pressed.connect(show_panel.bind($RepairPopover))
	$TabButtonBox/ShopButton.pressed.connect(show_panel.bind($ShopPopover))
	
	reset()
	
	if get_parent() == get_tree().root:
		_game = GameSpec.get_in_progress_game()
		update_info()
