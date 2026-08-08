extends ScrollContainer

static var ALL_FONT_COLORS := [
	"font_color",
	"font_hover_color",
	"font_focused_color",
]

var remove_forever_mode := false:
	set(v):
		remove_forever_mode = v
		if remove_forever_mode:
			%ModeButton.text = "Removing broken picks forever"
			for override in ALL_FONT_COLORS:
				%ModeButton.add_theme_color_override(override, Color("bd4844"))
		else:
			%ModeButton.text = "Enable remove forever mode"
			for override in ALL_FONT_COLORS:
				%ModeButton.remove_theme_color_override(override)

func toggle_remove_forever() -> void:
	remove_forever_mode = not remove_forever_mode

func load_cards(cards: Array[CardSpec]) -> void:
	for card in cards:
		var card_button := CardButton.build_from_spec(card)
		%CardGrid.add_child(card_button)

func _ready() -> void:
	%ModeButton.pressed.connect(toggle_remove_forever)

	if get_tree().current_scene == self:
		load_cards(GameSpec.get_in_progress_game().broken_picks)
