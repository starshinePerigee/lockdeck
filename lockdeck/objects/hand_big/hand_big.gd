extends Control
# The view for the hand and all the cards in it

## Raised when a card is clicked or a drag starts
signal card_selected(card: CardSpec)

signal card_tapped(space: CardSpace)
signal card_dragged(space: CardSpace)
signal card_dropped(space: CardSpace)

signal animation_complete()

const CARD_SPACE := preload("res://objects/card/card_space.tscn")
# starts at "1 card"
const CARD_WIDTH := 128
const SIZE_SCALE := [0, 25, 15, 0, -10, -25, -40, -52, -60, -66, -70, -73, -75]
const HIDE_OFFSET := 102
const HIDE_DURATION := 0.23
const CARD_SPEED_PX_PER_SEC := 1600

# set these from main
var deck_pos := Vector2(0, 500)
var discard_pos := Vector2(1000, 500)

## Disables meaningful card interactions
var disabled := false:
	set(v):
		disabled = v
		for child in $Hand.get_children():
			child.disabled = disabled

var _tween: Tween = null

func _tween_to(new_pos: int) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property($Hand, "position:y", new_pos, HIDE_DURATION)

## Hides (moves out of the way) the hand
func hide_hand() -> void:
	_tween_to(HIDE_OFFSET)

func unhide_hand() -> void:
	_tween_to(0)

## holds the card space ref in order
var spaces: Array[CardSpace] = []

func live_specs() -> Array[CardSpec]:
	var specs: Array[CardSpec] = []
	specs.assign(spaces.map(func(x): return x.card_spec))
	return specs

func _remove_space(space: CardSpace):
	if space in spaces:
		spaces.erase(space)
	else:
		push_error("Hand space refs lost track of child!")
	
	var card_pos: Vector2 = space.find_child("PickCard").global_position
	var duration: float = (
		card_pos.distance_to(discard_pos)
		/ (CARD_SPEED_PX_PER_SEC * 3)
		+ 0.14
	)
	var tween := space.tween_to(discard_pos.x, duration)
	if space in $Hand.get_children():
		tween.tween_callback($Hand.remove_child.bind(space))
	else:
		push_error("Hand parent lost track of ref!")
	tween.tween_callback(space.queue_free)
	space.arc_to(discard_pos.y, 150, duration)

func _add_space(spec: CardSpec) -> CardSpace:
	var space := CARD_SPACE.instantiate()
	space.card_spec = spec
	space.has_card = true
	$Hand.add_child(space)
	
	space.card_tapped.connect(card_selected.emit.bind(spec))
	space.card_picked_up.connect(card_selected.emit.bind(spec))
	space.card_tapped.connect(card_tapped.emit.bind(space))
	space.card_picked_up.connect(card_dragged.emit.bind(space))
	space.card_dropped.connect(card_dropped.emit.bind(space))
	
	space.position = Vector2()
	spaces.append(space)
	return space

## Forces full redraw
func redraw(cards: Array[CardSpec]) -> void:
	for card in cards.duplicate():
		if not(card):
			push_error("Null card spec passed to hand?")
			cards.erase(card)
	
	for space in spaces.duplicate():
		if space.card_spec not in cards:
			_remove_space(space)
	
	var specs := live_specs()
	for card in cards:
		if card not in specs:
			_add_space(card)
	
	# we gotta do this shit manually for dumb godot reasons
	var sep_index := clampi(len(cards) - 1, 0,len(SIZE_SCALE) - 1)
	var separation: int = SIZE_SCALE[sep_index]
	var space_delta := CARD_WIDTH + separation
	var total_size := len(cards) * space_delta
	var start_pos := ((size.x - total_size) - 64) / 2
	
	var last_tween: Tween
	for i in len(spaces):
		spaces[i].z_index = 100 * i + 10
		var end_pos := start_pos + ((CARD_WIDTH + separation) * i)
		var duration := end_pos / CARD_SPEED_PX_PER_SEC
		last_tween = spaces[i].tween_to(end_pos, duration)
		if spaces[i].position == Vector2():
			spaces[i].arc_to(0, 10, duration)
	if last_tween:
		last_tween.tween_callback(animation_complete.emit)
	else:
		animation_complete.emit.call_deferred()

func get_spaces() -> Array[CardSpace]:
	return spaces

func _ready() -> void:
	redraw([])
	if get_tree().current_scene == self:
		redraw(PickGenerator.get_many_base_cards(7))
