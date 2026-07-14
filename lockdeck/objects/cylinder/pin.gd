extends Control
## The view for a single pin in the lock, made up of multiple depths.
class_name Pin

## Emitted if pin is clicked (anywhere)
signal pin_clicked()

## Emitted if a card enters
signal card_entered_pin()

## Emitted when a card exits
signal card_exited_pin()

## Vertical height of a depth texture in pixels.
const DEPTH_VHEIGHT := 32
const _DEPTH := preload("res://objects/cylinder/depth.tscn")

## Reference to each depth object, so adding children doesn't break things.
var depth_refs: Array[Depth] = []

## Holds hint colors
static var HINT_COLORS: Dictionary[PinSpec.RevealLevel, Color] = {
	PinSpec.RevealLevel.CLEAR: Color("7ac259"),
	PinSpec.RevealLevel.INTERESTING: Color("ffbc57"),
	PinSpec.RevealLevel.DANGEROUS: Color("#f1504b"),
}

#region display logic
## If this pin is "locked" - displayed as greyed out.
@export var pin_locked: bool = false:
	set(v):
		pin_locked = v
		if pin_locked:
			$Stack.modulate = Color("848484")
		else:
			$Stack.modulate = Color("ffffff")

## Current position of the pin. 0 is all the way down, and 8 is all the way up.
@export var pin_position: int = 0:
	set(v):
		pin_position = v
		
		if not is_node_ready():
			await ready
		
		$Stack.position = Vector2(
			0,
			DEPTH_VHEIGHT * PinSpec.PIN_DEPTH_COUNT 
			- DEPTH_VHEIGHT * (v + 1)
		)

## Hides the pin, visually.
## I don't remember why I use this instaead of just self.visible?
## games james ¯\_(ツ)_/¯
## Ed note: I think it's because self.visible removes it from the hbox layout
@export var visible_: bool = false:
	set(v):
		visible_ = v
		
		if not is_node_ready():
			await ready
		
		$Stack.visible = visible_
		$JamIndicator.visible = visible_
		$KeyIndicator.visible = visible_

## The value of the jam indicator, and if one is present. If jam count is less than or equal
## to zero, hide the jam indicator.
@export var jam_count: int = 0:
	set(v):
		jam_count = v
		
		if not is_node_ready():
			await ready
		
		$JamIndicator.visible = jam_count > 0
		$JamIndicator/JamCount.text = str(jam_count)

var _key_visible := false

## Load a PinSpec into this pin, setting all parameters.
func load_spec(pin_spec: PinSpec) -> void:
	if depth_refs.is_empty():
		return
		
	for i in min(PinSpec.PIN_DEPTH_COUNT, len(depth_refs)):
		depth_refs[i].flavor = pin_spec.get_visible(i)
		var reveal_level := pin_spec.reveals[i]
		if reveal_level in [
			PinSpec.RevealLevel.DANGEROUS,
			PinSpec.RevealLevel.INTERESTING,
			PinSpec.RevealLevel.CLEAR
		]:
			depth_refs[i].set_hints(pin_spec.hint_tracks[i], HINT_COLORS[reveal_level])
		else:
			depth_refs[i].set_hints("")
		depth_refs[i].result = Results.EMPTY
	
	pin_position = pin_spec.pin_position
	jam_count = pin_spec.jam_count
	_key_visible = pin_spec.is_solved()
	$KeyIndicator.visible = _key_visible

func load_results(results: ResultSpec) -> void:
	for i in len(depth_refs):
		if i in results.results:
			depth_refs[i].result = results.results[i]
		else:
			depth_refs[i].result = Results.EMPTY
		depth_refs[i].show_jam_result = i == results.jam_depth
	$Stack/BreakResult.visible = (
		len(depth_refs) in results.results
		and results.results[len(depth_refs)] == Results.BREAK
	)

func clear_results() -> void:
	for depth in depth_refs:
		depth.result = Results.EMPTY
		depth.show_jam_result = false

func load_previouses(effects: Array[EffectSpec]) -> void:
	for i in len(effects):
		for d in effects[i].realized_positions.keys():
			if d < len(depth_refs):
				depth_refs[d].add_previous_icon(i, effects[i].flavor)

func load_activations(activations: Array[bool]) -> void:
	for i in len(activations):
		depth_refs[i].exhausted = activations[i]

func clear_previouses() -> void:
	for depth in depth_refs:
		depth.clear_previous_icons()
		depth.exhausted = false

## Show all the previously loaded previous icons
func set_previouses_visibility(show_previous: bool) -> void:
	for depth in depth_refs:
		depth.show_previous = show_previous
		depth.show_exhausted = show_previous
	if show_previous:
		$JamIndicator.visible = false
		$KeyIndicator.visible = false
	else:
		$JamIndicator.visible = jam_count > 0
		$KeyIndicator.visible = _key_visible

#endregion

#region input logic
## Handle mouse clicks
func _handle_input(event: InputEvent) -> void:
	if not visible_:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pin_clicked.emit()

func _handle_enter_exit(area: Area2D, entered: bool) -> void:
	if not visible_:
		return
	var parent := area.get_parent()
	if parent is PickCard:
		if entered:
			card_entered_pin.emit()
		else:
			card_exited_pin.emit()

#endregion

func _ready() -> void:
	depth_refs = []
	for i in PinSpec.PIN_DEPTH_COUNT:
		var next_depth := _DEPTH.instantiate()
		if i == 0:
			next_depth.flavor = Depths.BASE
		elif i == PinSpec.PIN_DEPTH_COUNT - 1:
			next_depth.flavor = Depths.FINAL
		depth_refs.append(next_depth)
		$Stack/Depths.add_child(next_depth)
	
	gui_input.connect(_handle_input)
	$DropArea.area_entered.connect(_handle_enter_exit.bind(true))
	$DropArea.area_exited.connect(_handle_enter_exit.bind(false))
	
	load_spec(PinSpec.new())
