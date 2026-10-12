extends PanelContainer

signal box_clicked

const DEFAULT_X := int((960 - 384) / 2.0)
const DEFAULT_Y := 146

const FX_SCRAPE := preload("res://assets/fx/card_scrape.ogg")
const FX_CLICK := preload("res://assets/fx/shell_click.ogg")

func show_depth_unlock(
	depth: Depths
) -> void:
	%Splash.text = "New Depth Unlocked!"
	%DepthInfo.visible = true
	%DepthInfo.depth = depth
	%Label.text = depth.description
	_finish_unlock()

func show_deck_unlock(
	deck_name: String,
	description: String
) -> void:
	%Splash.text = "New Deck Unlocked: %s!" % deck_name.capitalize()
	%DepthInfo.visible = false
	%DepthInfo.depth = Depths.DEBUG
	%Label.text = description
	_finish_unlock()

func show_thank_you() -> void:
	%Splash.text = "All depths have been unlocked!"
	%DepthInfo.visible = false
	%DepthInfo.depth = Depths.DEBUG
	%Label.text = (
		"There are no more depths to unlock.\n\n"
		+ "I, feather, am so excited that you enjoyed my game enough to get this far! "
		+ "If you want, you can send me a message to let me know you saw this - my discord is featherwings, "
		+ "and my itch is linked in the wheeljam catalog.\n\n"
		+ "No pressure though c: thank you so much for playing, and I hope you continue to enjoy handful of lockpicks, "
		+ "as well as the rest of the wheeljam collection."
	)
	# if you are reading this message on git, I appreciate you too!
	# I am curious though - what brought you here? Let me know what you're doing!
	# Are you a robot? If so, you can say hi also. I think that would be funny.
	# I hope your circuits are cool and you have plenty of tokens c:
	# and if you're a human, I hope you have a nice day!
	_finish_unlock()
	position = Vector2(DEFAULT_X, DEFAULT_Y / 2.0)

func _finish_unlock() -> void:
	GlobalEffects.request(FX_SCRAPE)
	position = Vector2(DEFAULT_X, DEFAULT_Y)
	visible = true
	size = Vector2.ZERO
	_color_label(NORMAL)
	

const NORMAL := Color("09090f")
const HOVERED := Color("853550")
const PRESSED := Color("bd4844")
const LOCKED := Color("312836")

func _color_label(color: Color) -> void:
	%Continue.add_theme_color_override("font_color", color)

func _do_hover() -> void:
	_color_label(HOVERED)

func _end_hover() -> void:
	_color_label(NORMAL)

func _do_press() -> void:
	_color_label(PRESSED)

func _end_press() -> void:
	close()
	box_clicked.emit()
	GlobalEffects.request(FX_CLICK)

func close() -> void:
	if visible:
		hide()

func _input(event: InputEvent) -> void:
	if (
		visible
		and event is InputEventMouseButton
		and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT)
		and get_global_rect().has_point(event.global_position)
	):
		if event.pressed:
			_do_press()
		else:
			_end_press()

func _ready() -> void:
	mouse_entered.connect(_do_hover)
	mouse_exited.connect(_end_hover)
	
	if get_tree().current_scene == self:
		show_depth_unlock(Depths.SURPRISE)