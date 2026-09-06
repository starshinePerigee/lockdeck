extends Control
## The view for a single pin in the lock, made up of multiple depths.
class_name Pin

signal animation_complete()

## Vertical height of a depth texture in pixels.
const DEPTH_VHEIGHT := 32
const _DEPTH := preload("res://objects/cylinder/depth.tscn")

const PER_DEPTH_DELAY := 0.15
const PRE_ACTIVATION_DELAY := 0.3

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

func _stack_position(pos: int) -> Vector2:
	return Vector2(
		0,
		DEPTH_VHEIGHT * (PinSpec.PIN_DEPTH_COUNT - 1)  
		- DEPTH_VHEIGHT * pos
	)

## Current position of the pin. 0 is all the way down, and 8 is all the way up.
@export var pin_position: int = 0:
	set(v):
		pin_position = v
		
		if not is_node_ready():
			await ready
		
		$Stack.position = _stack_position(pin_position)
		
		# this logic handles skewing the spring as a hack
		var depth_shift := DEPTH_VHEIGHT * pin_position
		var pin_shift := depth_shift / 3.0
		$Stack/Spring.size = Vector2(SPRING_SIZE.x, SPRING_SIZE.y - pin_shift)
		$Stack/Spring.position = Vector2(SPRING_POSITION.x, SPRING_POSITION.y + pin_shift)

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
		$Stack/Spring.visible = visible_

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

var _tween: Tween
var _pending_spec: PinSpec

var _mid_pos: int

func _tween_to(pos: int, speed_scale := 1.0) -> void:
	if _mid_pos == pos:
		return
	
	_tween.tween_property(
		$Stack,
		"position",
		_stack_position(pos),
		PER_DEPTH_DELAY * speed_scale
	)
	_mid_pos = pos

func _activate_delay() -> void:
	_tween.tween_interval(PRE_ACTIVATION_DELAY)

func _reset_trans() -> void:
	_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _tween_reveal(pos: int) -> void:
	_tween.tween_property(depth_refs[pos], "flavor", _pending_spec.depths[pos], 0)

func animate(
	pin_spec: PinSpec,
	effects: Array[EffectSpec]
) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	
	if _pending_spec:
		load_spec(_pending_spec)
	_pending_spec = pin_spec
	
	if jam_count:
		for effect in effects:
			if effect.flavor in [Effects.PUSH, Effects.TEST, Effects.REVEAL]:
				jam_count = 0
	
	_mid_pos = pin_position
	for effect in effects:
		_animate_effect(effect)
	_tween_to(
		pin_spec.pin_position, 
		0.8 * abs(_mid_pos - pin_spec.pin_position)
	)
	_tween.tween_callback(_finish_animation)

## Animate a specific effect/depth combo. at the end of this, the pin's stack should be
## showing at the specific depth
func _animate_effect(effect: EffectSpec):
	match effect.flavor:
		Effects.SAFE_PUSH, Effects.BOUNCE:
			_tween_to(effect.realized_origin)
			_tween_reveal(effect.realized_origin)
			_activate_delay()
			_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			var pos: int
			var delay: float
			if effect.flavor == Effects.SAFE_PUSH:
				delay = PER_DEPTH_DELAY
				pos = effect.last()
			else:
				delay = PER_DEPTH_DELAY * 2
				pos = effect.first()
			_tween.tween_property($Stack, "position", _stack_position(pos), delay)
			_mid_pos = pos
			_reset_trans()
		Effects.PUSH, Effects.TEST:
			for depth in effect.realized_positions.keys():
				var speed_scale: float
				if effect.flavor == Effects.TEST:
					speed_scale = 1.0
				else:
					speed_scale = 1.2
				_tween_to(depth, speed_scale)
				if (
					(depth < len(depth_refs) and depth >= 0)
					and depth_refs[depth].flavor in [Depths.HIDDEN]
				):
					_tween.tween_property(depth_refs[depth], "flavor", Depths.MARK_PENDING, 0)
		Effects.SKIP:
			_tween_to(effect.last(), 0.5)
		Effects.JAM:
			_tween_to(effect.last(), abs(_mid_pos - effect.last()))
			for shake in [-3, 3, 0]:
				_tween.tween_property($Stack, "position:x", shake, 0.05)
		Effects.UNJAM:
			var base_pos := _stack_position(_mid_pos)
			for shake in [Vector2(-1, -16), Vector2(0, -10), Vector2(-1, -12), Vector2(0, 0)]:
				_tween.tween_property($Stack, "position", base_pos + shake, 0.04)
		Effects.REVEAL:
			for depth in effect.realized_positions.keys():
				_tween_to(depth)
				_tween_reveal(depth)
		_:
			if effect.real():
				_tween_to(effect.last())

func _finish_animation() -> void:
	load_spec(_pending_spec)
	_pending_spec = null
	animation_complete.emit()

func direct_load(pin_spec: PinSpec) -> void:
	load_spec(pin_spec)
	animation_complete.emit()

## Load a PinSpec into this pin, setting all parameters directly without animation.
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
	SPRING_POSITION = $Stack/Spring.position
	SPRING_SIZE = $Stack/Spring.size

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
