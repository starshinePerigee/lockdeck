extends Control
## The view for a single pin in the lock, made up of multiple depths.
class_name Pin

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

const BOMB_LIVE := preload("res://assets/pin/its_a_bomb.png")
const BOMB_DEAD := preload("res://assets/pin/bomb_defused.png")

#region display logic
## If this pin is "locked" - displayed as greyed out.
@export var pin_locked: bool = false:
	set(v):
		pin_locked = v
		if pin_locked:
			$Stack.modulate = Color("848484")
		else:
			$Stack.modulate = Color("ffffff")

var SPRING_SIZE: Vector2
var SPRING_POSITION: Vector2

## Current position of the pin. 0 is all the way down, and 8 is all the way up.
@export var pin_position: int = 0:
	set(v):
		pin_position = v
		
		if not is_node_ready():
			await ready
		
		var depth_shift := DEPTH_VHEIGHT * v
		$Stack.position = Vector2(
			0,
			DEPTH_VHEIGHT * (PinSpec.PIN_DEPTH_COUNT - 1)  
			- depth_shift
		)
		
		# this logic handles skewing the spring as a hack
		@warning_ignore("integer_division")
		var pin_shift = depth_shift / 3
		$Spring.size = Vector2(SPRING_SIZE.x, SPRING_SIZE.y - pin_shift)
		$Spring.position = Vector2(SPRING_POSITION.x, SPRING_POSITION.y - (depth_shift - pin_shift))

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
		$Spring.visible = visible_

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

func _draw_bomb(defused := false) -> void:
	if not $Stack/BombIndicator.visible:
		return
	if defused:
		$Stack/BombIndicator/BombIcon.texture = BOMB_DEAD
	else:
		$Stack/BombIndicator/BombIcon.texture = BOMB_LIVE

## Load a PinSpec into this pin, setting all parameters.
func load_spec(pin_spec: PinSpec) -> void:
	if depth_refs.is_empty():
		return
		
	for i in min(PinSpec.PIN_DEPTH_COUNT, len(depth_refs)):
		depth_refs[i].flavor = pin_spec.get_visible(i)
		depth_refs[i].exhausted = pin_spec.activated[i]
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
	
	if pin_spec.bomb_pos >= 0:
		$Stack/BombIndicator.visible = true
		$Stack/BombIndicator.position.y = DEPTH_VHEIGHT * pin_spec.bomb_pos
	else:
		$Stack/BombIndicator.visible = false
	_draw_bomb()
	
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
	_draw_bomb(results.bomb_defused)

func clear_results() -> void:
	for depth in depth_refs:
		depth.result = Results.EMPTY
		depth.show_jam_result = false
	$Stack/BreakResult.visible = false
	_draw_bomb()
#endregion

func get_drop_area() -> Area2D:
	return $DropArea

func get_mouse_rect() -> Rect2:
	return get_global_rect()

func core_highlight() -> void:
	pass

func core_unhighlight() -> void:
	pass

func core_hover() -> void:
	pass

func core_unhover() -> void:
	pass

func _ready() -> void:
	SPRING_POSITION = $Spring.position
	SPRING_SIZE = $Spring.size

	depth_refs = []
	for i in PinSpec.PIN_DEPTH_COUNT:
		var next_depth := _DEPTH.instantiate()
		if i == 0:
			next_depth.flavor = Depths.BASE
		elif i == PinSpec.PIN_DEPTH_COUNT - 1:
			next_depth.flavor = Depths.FINAL
		depth_refs.append(next_depth)
		$Stack/Depths.add_child(next_depth)
	
	load_spec(PinSpec.new())
