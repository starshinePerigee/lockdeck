@tool
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

#region display logic
## If this pin is "set" - aka, jammed and won't fall at the next fall step.
@export var pin_set: bool = false:
	set(v):
		pin_set = v
		if pin_set:
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
		
		if jam_count > 1:
			jam_visible = true
		$JamIndicator/JamCount.text = str(jam_count)

@export var jam_visible: bool = false:
	set(v):
		jam_visible = v
		
		if not is_node_ready():
			await ready
		
		$JamIndicator.visible = jam_visible

## If the unlock indicator is visible.
@export var key_set: bool = false:
	set(v):
		key_set = v
		
		if not is_node_ready():
			await ready
		
		$KeyIndicator.visible = key_set

## Load a PinSpec into this pin, setting all parameters.
func load_spec(pin_spec: PinSpec) -> void:
	if depth_refs.is_empty():
		return
		
	for i in min(PinSpec.PIN_DEPTH_COUNT, len(depth_refs)):
		depth_refs[i].flavor = pin_spec.depths[i]
		depth_refs[i].revealed = pin_spec.reveals[i]
	
	pin_position = pin_spec.pin_position
	jam_count = pin_spec.jam_count
	jam_visible = pin_spec.jam_visible
	pin_set = pin_spec.pin_set
	key_set = pin_spec.key_set

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
			next_depth.revealed = true
		elif i == PinSpec.PIN_DEPTH_COUNT - 1:
			next_depth.flavor = Depths.FINAL
			next_depth.revealed = true
		depth_refs.append(next_depth)
		$Stack/Depths.add_child(next_depth)
	
	gui_input.connect(_handle_input)
	$DropArea.area_entered.connect(_handle_enter_exit.bind(true))
	$DropArea.area_exited.connect(_handle_enter_exit.bind(false))
	
	load_spec(PinSpec.new())
