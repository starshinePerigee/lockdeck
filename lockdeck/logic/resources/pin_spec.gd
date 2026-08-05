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
## Checks if depths have been tested this turn
@export var checked: Array[bool]
## Checks if depths have been activated this turn
@export var activated: Array[bool]
## Holds the checked tracking letters
@export var hint_tracks: Array[String]
## Current depth index for the pin. Starts at 0, increases as the pin is picked.
@export var pin_position: int
## Tracks if the pin has moved and thus is due for activation
@export var activation_pending: bool
## Tracks the current test/reveal hint pointer. Measures positions beyond current position.
@export var sight_pointer: int
## If the pin has a jam value. Greater than 0 will show the jam indicator.
@export var jam_count: int

## Get the depth flavor that the pin is currently set to
## (if it hasn't been activated yet)
func activate_and_get_depth() -> Depths:
	activation_pending = false
	if activated[pin_position]:
		return Depths.EXHAUSTED
	else:
		activated[pin_position] = true
		reveal_position(pin_position)
		return depths[pin_position]
	# tutorialization guide: should emit a signal that triggers an explainer

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

## Resets all single-execution values
func end_step() -> void:
	checked.fill(false)
	activated.fill(false)
	activation_pending = false
	sight_pointer = 0

## Get if the pin is currently revealed
func get_revealed(idx: int) -> bool:
	return reveals[idx] == RevealLevel.REVEALED

## Get if the pin was checked (and not revealed)
func get_checked(idx: int) -> bool:
	return checked[idx] and not get_revealed(idx)

## Returns true if the pin is currently solved.
func is_solved() -> bool:
	return depths[pin_position] in Depths.SOLVE_DEPTHS

## Returns true if the pin is currently jammed
func is_jammed() -> bool:
	return jam_count > 0

## Checks a depth (or the current depth is none is provided), if it's not revealed
func test_position(pos: int = -1) -> void:
	if pos == -1:
		pos = pin_position
	checked[pos] = true

## Reveals a depth (or the current depth if none is provided)
func reveal_position(pos: int = -1) -> void:
	if pos == -1:
		pos = pin_position
	reveals[pos] = RevealLevel.REVEALED
	hint_tracks[pos] = ""

## Crush (set depth to empty and reveal) a depth (or current depth if none provided)
## returns true if this breaks the pick, and false otherwise
func crush_position(pos: int = -1) -> void:
	if pos == -1:
		pos = pin_position
	var depth := depths[pos]
	reveal_position(pos)
	if depth not in [Depths.FINAL, Depths.BASE]:
		depths[pos] = Depths.EMPTY

## Handle jam and move the pin accordingly
func push_pin(effect: EffectSpec) -> void:
	_push_crush(effect)

func crush_pin(effect: EffectSpec) -> void:
	_push_crush(effect)

func _push_crush(effect: EffectSpec) -> void:
	var remainder := push_jam(effect.value)
	if remainder < 0:
		effect.set_jammed(pin_position)
		return
	
	activation_pending = true
	
	for __ in effect.value:
		if effect.flavor == Effects.CRUSH:
			crush_position()

		if advance_pin(1):
			effect.oobed = true
			activation_pending = false
			if pin_position == PIN_DEPTH_COUNT - 1:
				effect.unlock_pin = true
		
		effect.add_position(pin_position)
		if effect.broke_pick or effect.oobed:
			break
		
		if effect.flavor == Effects.PUSH:
			# we only need to test, since we will activate (which reveals) later
			# based on activation_pending 
			test_position(pin_position)

## Bounce the pin backwards
func bounce_pin(effect: EffectSpec) -> void:
	activation_pending = true
	for __ in effect.value:
		var oob := advance_pin(-1)
		effect.add_position(pin_position)
		if oob:
			return

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
	
	jam_count += effect.value
	effect.add_position(pin_position)

## Clears jam, setting it to 0.
func clear_jam() -> void:
	jam_count = 0

## Advance the sight pointer forward by a value
func advance_sight_pointer(value: int) -> void:
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
			test_position(target)
		elif effect.flavor == Effects.REVEAL:
			reveal_position(target)

## Resets the pin to default values but does not change depths.
func reset_pin() -> void:
	pin_position = 0
	jam_count = 0
	end_step()

func _init(fill: Depths = Depths.DEBUG):
	depths = []
	depths.resize(PIN_DEPTH_COUNT)
	depths.fill(fill)
	depths[0] = Depths.BASE
	depths[-1] = Depths.FINAL
	
	reveals = []
	reveals.resize(PIN_DEPTH_COUNT)
	reveals.fill(RevealLevel.UNKNOWN)
	reveals[0] = RevealLevel.REVEALED
	reveals[-1] = RevealLevel.REVEALED
	
	checked = []
	checked.resize(PIN_DEPTH_COUNT)
	checked.fill(false)
	
	activated = []
	activated.resize(PIN_DEPTH_COUNT)
	activated.fill(false)
	
	hint_tracks = []
	hint_tracks.resize(PIN_DEPTH_COUNT)
	hint_tracks.fill("ABC")

	reset_pin()
