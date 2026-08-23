extends Resource
## PinSpec is the dataclass that describes a single pin's status.
## It includes an array of depth flavors, depth reveal statuses, 
## as well as other pin information like jam and unlock indicatiors.
class_name PinSpec

## Maxmimum number of cylinders.
## This is a deep assumption - changing this will break *everything*.
## so dont.
const CYLINDER_COUNT_MAX := 5

## Number of depths
## This is also pretty deep so maybe don't touch it?
const PIN_DEPTH_COUNT := 9

enum RevealLevel {
	REVEALED = 0,
	CLEAR = 1,
	INTERESTING = 2,
	DANGEROUS = 3,
	UNKNOWN = 4,
}

## Array of depth flavors for this pin. Index 0 is the top flavor, and
## will typically be Depths.BASE
@export var depths: Array[Depths]
## Revealed status array.
@export var reveals: Array[RevealLevel]
## Checks if depths have been tested this execution
@export var checked: Array[bool]
## Checks if depths have been activated this turn
@export var activated: Array[bool]
## Holds the results objects for this pin activation
## Size is ONE PLUS the size of depths to handle the overrun result
@export var results: Array[Results]
## Holds how many twist depths are triggered this execution
@export var twist_count: int
## holds how much more push is pending in a push action
var _push_pending: int
## Holds the checked tracking letters
@export var hint_tracks: Array[String]
## Current depth index for the pin. Starts at 0, increases as the pin is picked.
@export var pin_position: int
## Tracks the current test/reveal hint pointer. Measures positions beyond current position.
@export var sight_pointer: int
## If the pin has a jam value. Greater than 0 will show the jam indicator.
@export var jam_count: int
## If there is a currently active bomb, what depth it is - otherwise -1
@export var bomb_pos: int
## Used for results display
var _bomb_defused: bool

#region tracking modifiers
## Get the visible depth for a pin, or the current one (default)
## Negative numbers index from the back 
func get_visible(idx: int = 99) -> Depths:
	if idx == 99:
		idx = pin_position
	match reveals[idx]:
		RevealLevel.REVEALED:
			return depths[idx]
		RevealLevel.UNKNOWN:
			return Depths.HIDDEN
		RevealLevel.CLEAR:
			return Depths.MARK_CLEAR
		RevealLevel.INTERESTING:
			return Depths.MARK_INTERESTING
		RevealLevel.DANGEROUS:
			return Depths.MARK_DANGEROUS
	return Depths.DEBUG

## Updates a level's reveal level, setting it to the highest option.
func update_visible(idx: int, level: RevealLevel, hint: String) -> void:
	var old_reveal := reveals[idx]
	var new_reveal: RevealLevel = min(old_reveal, level)
	reveals[idx] = new_reveal
	
	if get_revealed(idx):
		hint_tracks[idx] = ""
	elif old_reveal != new_reveal:
		hint_tracks[idx] = hint
	elif old_reveal == level:
		hint_tracks[idx] = hint_tracks[idx] + hint 

## Get if the pin is currently revealed
func get_revealed(idx: int) -> bool:
	return reveals[idx] <= RevealLevel.REVEALED

## Get if the pin was checked (and not revealed)
func get_checked(idx: int) -> bool:
	return checked[idx] and not get_revealed(idx)

## Returns true if the pin is currently solved.
func is_solved() -> bool:
	return pin_position == PIN_DEPTH_COUNT - 1

## Returns true if the pin is currently jammed
func is_jammed() -> bool:
	return jam_count > 0

## Returns true if the current depth has been activated
func is_exhausted() -> bool:
	return activated[pin_position]

## Update the results tracking for this specific pin
func update_result(new_result: Results, pos: int = -1) -> void:
	if pos == -1:
		pos = pin_position
	if pos >= 0 and pos < len(results):
		results[pos] = Results.compare(results[pos], new_result)
#endregion

#region execution handling
## Process a series of effects
## This will update effects in-place with execution info,
## And return any new effects to record
func execute(pending_effects: Array[EffectSpec]) -> Array[EffectSpec]:
	var old_bomb := bomb_pos
	bomb_pos = -1
	
	if len(pending_effects) > 0:
		_execute_effects(pending_effects)
	
	var additional_effects: Array[EffectSpec] = []
	
	if old_bomb >= 0:
		var bomb_effect: EffectSpec
		if old_bomb >= pin_position:
			# boom
			update_result(Results.BREAK, old_bomb)
			bomb_effect = EffectSpec.new(Effects.BREAK)
			bomb_effect.broke_pick = true
		else:
			bomb_effect = EffectSpec.new(Effects.BOMB_DEFUSED)
			_bomb_defused = true
		bomb_effect.add_position(old_bomb)
		additional_effects.append(bomb_effect)
	
	return additional_effects

func _execute_effects(pending_effects: Array[EffectSpec]) -> void:
	update_result(Results.HOME)
	for effect in pending_effects:
		# print(
		# 	"Executing effect %s with value %s" 
		# 	% [effect.flavor.effect_name, effect.value]
		# )
		execute_effect(effect)
	
	if is_exhausted():
		update_result(Results.EXHAUSTED)
	else:
		update_result(Results.ACTIVATE)

## Activates the pin, doing the effect for the depth it is on
func activate() -> EffectSpec:
	# activate the pin:
	var depth := activate_and_get_depth()
	var effect := EffectSpec.new(depth.effect, depth.value)
	# print(
	# 	"Activating pin at depth %s with effect %s"
	# 	% [pin_position, effect.effect_name]
	# )
	execute_effect(effect)
	return effect

## Execute a single effect
func execute_effect(effect) -> void:
	match effect.flavor:
		# ALL OF THE GAME LOGIC GOES HERE: 
		# (BALATRO REFERENCE LMAO)
		Effects.EMPTY:
			pass
		Effects.DISARM:
			pass
		Effects.PUSH:
			push_pin(effect)
		Effects.SAFE_PUSH:
			push_pin(effect, true)
		Effects.TEST:
			test_pin(effect)
		Effects.REVEAL:
			reveal_pin(effect)
		Effects.JAM:
			add_jam(effect)
		Effects.SKIP:
			skip_pin_forward(effect)
		Effects.BOUNCE:
			bounce_pin(effect)
		Effects.LUCKY:
			lucky_boost(effect)
		Effects.HINT:
			do_hint()
		Effects.GATE_UNLOCK:
			do_gate_unlock()
		Effects.BOMB:
			do_bomb(pin_position)
		Effects.DRAW_FROM_DISCARD:
			# handled in end_step_spec
			pass
		Effects.BREAK_FROM_DECK:
			# handled in end_step_spec
			pass
		Effects.DISCARD_HAND:
			# handled in end_step_spec
			pass
		Effects.BREAK:
			handle_break(effect)
			return
		Effects.UNLOCK:
			unlock_pin(effect)
		Effects.DEBUG:
			push_error("DEBUG effect flavor called!")
		_:
			push_warning("Undefined effect flavor effect: %s" % effect.flavor)

## Update records for a triggered depth
func trigger_depth(pos: int, effect: EffectSpec, break_pick := false) -> void:
	activated[pos] = true
	reveal_position(pos, effect, true)
	
	if break_pick:
		update_result(Results.BREAK, pos)
		if effect != null:
			effect.broke_pick = true
	else:
		update_result(Results.TRIGGERED, pos)

## Called on each depth tested - used for on-test hooks
func on_test_trigger(pos: int, effect: EffectSpec) -> void:
	match get_live_depth(pos):
		Depths.TRAP:
			trigger_depth(pos, effect, true)
		Depths.TWIST:
			twist_count += 1
		Depths.BOMB:
			start_bomb(pos, effect)
		_:
			pass

## Called on each 
func on_reveal_trigger(pos: int, effect: EffectSpec) -> void:
	match get_live_depth(pos):
		Depths.TRAP:
			trigger_depth(pos, effect, true)
		Depths.LABYRINTH:
			trigger_depth(pos, effect, true)
		Depths.TWIST:
			twist_count += 1
		Depths.BOMB:
			start_bomb(pos, effect)
		_:
			pass

## Called when a pin is advanced past
func on_advance_trigger(pos: int, effect: EffectSpec) -> void:
	if pos > bomb_pos:
		bomb_pos = -1
	match get_live_depth(pos):
		Depths.GATE_LOCKED:
			effect.broke_pick = true
			update_result(Results.BREAK, pos)
		Depths.SLIP:
			trigger_depth(pos, effect)
			_push_pending += 1
		Depths.BOMB:
			trigger_depth(pos, effect)
		_:
			pass

## Called immediately when a pin is activated.
## Typical depth activation effects should be handled by cylinder_main
func on_activate_trigger(pos: int, effect: EffectSpec) -> void:
	match get_live_depth(pos):
		_:
			pass

func on_jam_trigger(pos: int, effect: EffectSpec) -> void:
	# handle catch logic
	if Depths.CATCH in depths:
		var catch_pos := -1
		for i in range(0, pos, 1):
			if get_live_depth(i) == Depths.CATCH:
				catch_pos = i
				break
		
		if catch_pos > 0:
			trigger_depth(catch_pos, effect, true)
	
	match get_live_depth(pos):
		_:
			pass

func start_bomb(pos: int, effect: EffectSpec) -> void:
	do_bomb(pos)
	trigger_depth(pos, effect)
#endregion

#region effect handling
## Gets the depth for a position if it is not exhausted, or EXHAUSTED otherwise
func get_live_depth(pos: int) -> Depths:
	if activated[pos]:
		return Depths.EXHAUSTED
	return depths[pos]

## Get the depth flavor that the pin is currently set to
## (if it hasn't been activated yet)
func activate_and_get_depth(effect: EffectSpec = null) -> Depths:
	reveal_position(pin_position, effect, true)
	
	var depth := get_live_depth(pin_position)
	
	if depth != Depths.EXHAUSTED:
		on_activate_trigger(pin_position, effect)
		activated[pin_position] = true
		update_result(Results.AUTO)
	
	return depth

## Checks a depth (or the current depth is none is provided), if it's not revealed
func test_position(pos: int = -1, effect: EffectSpec = null) -> void:
	if pos == -1:
		pos = pin_position
	
	on_test_trigger(pos, effect)
	
	if get_revealed(pos):
		update_result(Results.NONE, pos)
		return
	
	checked[pos] = true
	update_result(Results.HINT, pos)

## Reveals a depth (or the current depth if none is provided)
func reveal_position(
	pos: int = -1,
	effect: EffectSpec = null,
	from_activate := false
) -> void:
	if pos == -1:
		pos = pin_position
	
	if not from_activate:
		on_reveal_trigger(pos, effect)
	
	if get_revealed(pos):
		if not from_activate:
			update_result(Results.NONE, pos)
	else:
		reveals[pos] = RevealLevel.REVEALED
		update_result(Results.REVEAL, pos)
		hint_tracks[pos] = ""

## Handle jam and move the pin accordingly
func push_pin(effect: EffectSpec, safe := false) -> void:
	var remainder := push_jam(effect.value)
	if remainder <= 0:
		effect.set_jammed(pin_position)
		return
	
	_push_pending += remainder
	while _push_pending > 0:
		on_advance_trigger(pin_position, effect)
		test_position(pin_position)
		
		effect.add_position(pin_position + 1)
		_push_pending -= 1
		if advance_pin(1):
			_push_pending = 0
			effect.add_position(PIN_DEPTH_COUNT)
			if not safe:
				effect.broke_pick = true
				update_result(Results.BREAK, PIN_DEPTH_COUNT)
		if is_solved():
			update_result(Results.UNLOCK)

## Bounce the pin backwards
func bounce_pin(effect: EffectSpec) -> void:
	for __ in effect.value:
		var oob := advance_pin(-1)
		effect.add_position(pin_position)
		if oob:
			return

func lucky_boost(effect: EffectSpec) -> void:
	clear_jam()
	advance_pin(PIN_DEPTH_COUNT)
	effect.add_position(pin_position)

## Move the pin forward (if positive) or backwards (if negative), returning true if oob'ed.
func advance_pin(relative: int = 0, absolute: int = -1) -> bool:
	var oob := false
	if absolute >= 0:
		pin_position = absolute
		sight_pointer = absolute
	pin_position += relative
	sight_pointer = clamp(
		sight_pointer - abs(relative), 
		0,
		PIN_DEPTH_COUNT - pin_position - 1
	)
	if pin_position >= PIN_DEPTH_COUNT or pin_position < 0:
		pin_position = clamp(pin_position, 0, PIN_DEPTH_COUNT - 1)
		oob = true	
	return oob

## Check motion against jam.
## If advance > jam, returns remaining advance as positive integer;
## If advance < jam, returns remaining jam as negative integer;
## and if advance == jam returns 0
func push_jam(advance_by: int) -> int:
	var delta := advance_by - jam_count
	jam_count = max(0, -delta)
	return delta

## Adds jam. Use push_jam() to remove jam via motion.
func add_jam(effect: EffectSpec) -> void:
	if effect.value < 0:
		push_warning("Attempted negative jam application. This is deprecated!")
		return
	
	on_jam_trigger(pin_position, effect)
	jam_count += effect.value
	effect.add_position(pin_position)

## Clears jam, setting it to 0.
func clear_jam() -> void:
	jam_count = 0

## Advance the sight pointer forward by a value
func advance_sight_pointer(value: int) -> void:
	update_result(Results.SKIP, pin_position + sight_pointer)
	sight_pointer += value

## Skip the pin forward, moving the sight pointer
func skip_pin_forward(effect: EffectSpec) -> void:
	return _test_skip_reveal(effect)

## Tests the pin from the sight pointer, while incrementing it.
func test_pin(effect: EffectSpec) -> void:
	return _test_skip_reveal(effect)

## Reveals a pin from the sight pointer, while incrementing it
func reveal_pin(effect: EffectSpec) -> void:
	return _test_skip_reveal(effect)

func _test_skip_reveal(effect: EffectSpec) -> void:
	if is_jammed():
		effect.set_jammed(pin_position)
		return
	
	for __ in effect.value:
		advance_sight_pointer(1)
		var target := sight_pointer + pin_position
		if target >= PIN_DEPTH_COUNT:
			break
		effect.add_position(target)
		# it's a little cursed having this in here:
		if effect.flavor == Effects.TEST:
			test_position(target, effect)
		elif effect.flavor == Effects.REVEAL:
			reveal_position(target, effect)

## Handle an unlock effect
func unlock_pin(effect: EffectSpec) -> void:
	update_result(Results.UNLOCK)
	effect.add_position(pin_position)

## Handles a break effect
## Since breaks a property of the previous effect, this just updates tracking
func handle_break(effect: EffectSpec) -> void:
	update_result(Results.BREAK, pin_position)
	effect.broke_pick = true
	effect.add_position(pin_position)

func do_hint() -> void:
	# i can't believe range returns an untyped array
	# godot is not a serious language
	var check_order: Array = (
		range(pin_position, PIN_DEPTH_COUNT, 1)
		+ range(0, pin_position, 1)
	)
	for i in check_order:
		if not get_revealed(i) and depths[i].tests_as == Depths.DangerLevel.CLEAR:
			reveals[i] = RevealLevel.REVEALED
			return

func do_gate_unlock() -> void:
	for i in PIN_DEPTH_COUNT:
		if depths[i] == Depths.GATE_LOCKED:
			depths[i] = Depths.GATE_UNLOCKED
			activated[i] = true
			return

func do_bomb(pos) -> void:
	bomb_pos = pos
#endregion

#region ending and cleanup methods
## Gets the worst reveal level for this activated pin
func get_reveal_level() -> PinSpec.RevealLevel:
	var level := PinSpec.RevealLevel.REVEALED
	for i in range(PinSpec.PIN_DEPTH_COUNT):
		if get_checked(i):
			var depth := depths[i]
			if depth.tests_as == Depths.DangerLevel.DANGEROUS:
				level = max(level, PinSpec.RevealLevel.DANGEROUS)
			elif depth.tests_as == Depths.DangerLevel.INTERESTING:
				level = max(level, PinSpec.RevealLevel.INTERESTING)
			elif depth.tests_as == Depths.DangerLevel.CLEAR:
				level = max(level, PinSpec.RevealLevel.CLEAR)
			else:
				push_warning("Unusual depth during update visibility: %s" % depth.depth_name)
				level = max(level, PinSpec.RevealLevel.INTERESTING)
	return level

func update_pin_visible(level: PinSpec.RevealLevel, hint: String):
	for i in range(PIN_DEPTH_COUNT):
		if checked[i]:
			update_visible(i, level, hint)

## Gets a ResultsSpec for this pin's current configuration
func get_result_spec() -> ResultSpec:
	var result_spec := ResultSpec.new()
	var has_results := false
	for i in len(results):
		if Results.gt(results[i], Results.EMPTY):
			has_results = true
			result_spec.results[i] = results[i]
	if jam_count > 0 and has_results:
		result_spec.jam_depth = pin_position
	result_spec.bomb_defused = _bomb_defused
	return result_spec

## Gets a copy of this pin, except with hidden depths set to empty
## Used for running previews
func shadow_clone(shadow: PinSpec) -> void:
	for i in len(depths):
		if reveals[i] == RevealLevel.REVEALED:
			shadow.depths[i] = depths[i]
		else:
			shadow.depths[i] = Depths.EMPTY

## Reset parameters after running a simulation
func reset_shadow(shadow: PinSpec) -> void:
	shadow.end_step()
	shadow.pin_position = pin_position
	shadow.jam_count = jam_count
	shadow.bomb_pos = bomb_pos
	shadow.reveals.assign(reveals)
	shadow.activated.assign(activated)

## Resets all single-execution values
func end_step() -> void:
	results.fill(Results.EMPTY)
	checked.fill(false)
	sight_pointer = 0
	twist_count = 0
	_push_pending = 0
	_bomb_defused = false

func reset_exhaustion() -> void:
	activated.fill(false)
	activated[0] = true
	activated[-1] = true

## Performs the end of turn actions
func end_turn_and_fall() -> void:
	if is_jammed():
		clear_jam()
	else:
		advance_pin(0, 0)
	reset_exhaustion()
	end_step()

## Called after generation
func finalize() -> void:
	for i in PIN_DEPTH_COUNT:
		if depths[i] in Depths.REVEALED_AT_START:
			reveals[i] = RevealLevel.REVEALED

## Resets the pin to default values but does not change depths.
func reset_pin() -> void:
	pin_position = 0
	jam_count = 0
	bomb_pos = -1
	reset_exhaustion()
	end_step()
#endregion

func _init(fill: Depths = Depths.DEBUG):
	depths = []
	depths.resize(PIN_DEPTH_COUNT)
	depths.fill(fill)
	depths[0] = Depths.BASE
	depths[-1] = Depths.FINAL
	
	reveals = []
	reveals.resize(PIN_DEPTH_COUNT)
	reveals.fill(RevealLevel.UNKNOWN)
	
	checked = []
	checked.resize(PIN_DEPTH_COUNT)
	checked.fill(false)
	
	activated = []
	activated.resize(PIN_DEPTH_COUNT)
	activated.fill(false)
	
	results = []
	results.resize(PIN_DEPTH_COUNT + 1)
	results.fill(Results.EMPTY)
	
	hint_tracks = []
	hint_tracks.resize(PIN_DEPTH_COUNT)
	hint_tracks.fill("ABC")

	reset_pin()
