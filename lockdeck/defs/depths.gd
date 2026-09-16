extends Resource
## Stores all depths flavors as a hand-rolled enum equivalent
class_name Depths

enum DangerLevel {
	## Raises a warning if tested, but tests as interesting
	INVALID,
	REVEALED,
	CLEAR,
	INTERESTING,
	DANGEROUS
}

static func _get_texture(n: String) -> Resource:
	var res_str := "res://assets/depths/depth_%s.png" % [n]
	if ResourceLoader.exists(res_str):
		return load(res_str)
	else:
		return load("res://assets/depths/depth_debug.png")

## Internal depth name used for texture lookup
@export var depth_name: String
## Human readable name of this depth, in lower case.
var english_name: String
## Tooltip description for this depth
var description: String
## Depth texture (as seen in a pin)
var texture: Resource
## Effect flavor
var effect: Effects
## What the depth tests as
var tests_as: DangerLevel
## Default effect value
var value: int

static var static_registry: Dictionary[String, Depths] = {}

func _init(
	depth_name_: String = "",
	tests_as_: DangerLevel = DangerLevel.INVALID,
	effect_: Effects = Effects.DEBUG,
	description_: String = "",
	value_: int = 1,
	english_name_: String = "",
):
	depth_name = depth_name_
	description = description_
	texture = _get_texture(depth_name_)
	tests_as = tests_as_
	effect = effect_
	value = value_
	if english_name_:
		english_name = english_name_ 
	else:
		english_name = depth_name
	
	if depth_name != "":
		static_registry[depth_name] = self

#region fake depths
## Debug depth. Should not be used.
static var DEBUG := Depths.new(
	"debug", DangerLevel.INVALID, Effects.DEBUG, "Tell feather you saw this!"
)

## Pending depth. used for level generation
static var PENDING := Depths.new("pending")

## Execution only depth indicating a depth has already been activated this turn
## and is now not activating again
static var EXHAUSTED := Depths.new(
	"exhausted", DangerLevel.INVALID, Effects.EMPTY,
	"This depth has been activated and will not activate again this turn."
)
#endregion

#region regular depths
static var EMPTY := Depths.new(
	"empty", DangerLevel.CLEAR, Effects.EMPTY, 
	"A safe depth with no effects."
)

static var BASE := Depths.new(
	"base", DangerLevel.REVEALED, Effects.EMPTY,
	"The resting position of the pin. Does not activate."
)

static var FINAL := Depths.new(
	"final_neutral", DangerLevel.REVEALED, Effects.UNLOCK,
	"Reach this depth to solve this pin. Push past it to break your pick.",
	1, "final"
)

static var HIDDEN := Depths.new(
	"hidden", DangerLevel.INVALID, Effects.DEBUG,
	"Could be anything. Use test or reveal picks to learn more, or just activate it and see what happens."
)

static var MARK_CLEAR := Depths.new(
	"mark_clear", DangerLevel.INVALID, Effects.DEBUG,
	"Marked safe. You can push to this depth without worry, although it might be dangerous in other ways.",
	0, "marked safe"
)

static var MARK_INTERESTING := Depths.new(
	"mark_interesting", DangerLevel.INVALID, Effects.DEBUG,
	("Marked caution, but could also be safe. If you activate this depth, something might happen. "
	+ "but you can be sure it won't break your pick."),
	0, "marked caution"
)

static var MARK_DANGEROUS := Depths.new(
	"mark_dangerous", DangerLevel.INVALID, Effects.DEBUG,
	("Marked dangerous, but could be actually be caution or even safe. "
	+ "If you activate this depth, anything could happen, including your pick breaking."),
	0, "marked dangerous"
)

static var MARK_PENDING := Depths.new(
	"mark_pending", DangerLevel.INVALID, Effects.DEBUG,
	"This depth is pending the completion of the pin animation. How are you seeing this tooltip?",
	0, "marked pending"
)
#endregion

#region safe depths

## Push effect
static var PUSH := Depths.new(
	"push", DangerLevel.CLEAR, Effects.SAFE_PUSH, 
	(
		"An unstable depth that will bounce off your pick, advancing it by two additional depths. "
		+ "This won't break your pick, but that depth will activate next turn, so be careful."
	),
	2, "bounce"
)

## solves the pin instantly
static var LUCKY := Depths.new(
	"lucky", DangerLevel.CLEAR, Effects.LUCKY,
	(
		"A weakness in the lock lets you push from this depth all the way to the end. Lucky you!\n"
		+ "Unless you break a pick pushing this pin afterwards."
	)
)

## Reveals the next safe depth (if one) or sets the pin as clear
static var HINT := Depths.new(
	"hint", DangerLevel.CLEAR, Effects.HINT,
	"A safe depth that also reveals another safe on this pin, if one exists."
)

static var BREATH := Depths.new(
	"breath", DangerLevel.CLEAR, Effects.DRAW_FROM_DISCARD,
	(
		"This depth is particularly stable." 
		+ "Take a deep breath and draw two cards from the discard pile, or the deck if the discard is empty."
	),
	2
)

static var TWIST := Depths.new(
	"twist", DangerLevel.CLEAR, Effects.DISARM,
	(
		"A twist in the keyway makes working with this pin difficult. "
		+ "A card from your deck is discarded whenever you test or reveal this depth."
	)
)

# Labyrinth
static var LABYRINTH := Depths.new(
	"labyrinth", DangerLevel.CLEAR, Effects.DISARM,
	(
		"A complex set of turns confounds pulls in and shears apart fragile picks. "
		+ "If you reveal this depth with a reveal pick, the pick will break."
	) 
)

static var CATCH := Depths.new(
	"catch", DangerLevel.CLEAR, Effects.DISARM,
	(
		"A catch in the pin kicks back against lockpickers. "
		+ "If you are below this depth and apply jam to this pin, it breaks your pick. "
		+ "Like all pins, it does nothing if exhausted, so activating it disarms it."
	)
)

static var SLIP := Depths.new(
	"slip", DangerLevel.CLEAR, Effects.DISARM,
	(
		"A surprisingly smooth section of the cylinder accellerates the pin. "
		+ "When you push past pop, the pin advances one more depth. "
		+ "Be careful approaching the end of the pin."
	),
	1, "pop"
)

#endregion

#region interesting depths

## Jam effect
static var JAM := Depths.new(
	"jam", DangerLevel.INTERESTING, Effects.JAM, 
	"A rough section of the cylinder jams this pin by three jam.",
	3
)


## Bounces up four (or to the edge)
static var BOUNCE := Depths.new(
	"bounce", DangerLevel.INTERESTING, Effects.BOUNCE,
	(
		"Play in the pin causes it to slip off your pick, moving backwards four spaces."
	),
	4, "slip"
)

static var BOMB := Depths.new(
	"bomb", DangerLevel.INTERESTING, Effects.BOMB,
	(
		"Activating, testing, or revealing a bomb will cause it to light."
		+ "Once lit, you have one turn to advance past the bomb or it explodes, breaking your pick."
	)
)

static var FUMBLE := Depths.new(
	"fumble", DangerLevel.INTERESTING, Effects.DISCARD_HAND,
	"Discards your current hand. Whoops!"
)

#endregion

#region break depths

static var BREAK := Depths.new(
	"break", DangerLevel.DANGEROUS, Effects.BREAK,
	"A point of resistance in the pin. Activating it breaks your pick. Only present past a Warning depth."
)

## Does nothing except indicates a break is ahead somewhere
static var WARN := Depths.new(
	"warn", DangerLevel.CLEAR, Effects.EMPTY,
	"Does nothing if activated, but know that the Break depth is past this one.",
	1, "warning"
)

static var TRAP := Depths.new(
	"trap", DangerLevel.REVEALED, Effects.DISARM,
	(
		"A trap against lockpickers like yourself who might be probing around inside the lock. "
		+ "This breaks your pick if you try to test or reveal it, but not if you land on it or past it. "
		+ "Like all depths, it does nothing if exhausted, so activating it disarms it."
	)
)

static var SURPRISE := Depths.new(
	"surprise", DangerLevel.DANGEROUS, Effects.BREAK_FROM_DECK,
	(
		"Breaks the top card of your deck. Does nothing if your deck is empty."
	),
	1
)

static var SPIKE := Depths.new(
	"spike", DangerLevel.REVEALED, Effects.BREAK,
	(
		"An unsubtle security measure, this spike breaks your pick. This depth is revealed at the start of a lock."
	)
)

static var GATE_LOCKED := Depths.new(
	"gate_locked", DangerLevel.REVEALED, Effects.BREAK,
	(
		"A \"gate\" that requires that you visit an earlier, hidden \"key\" depth to unlock it safely. "
		+ "You could also just push past it, at the cost of your pick."
	),
	1, "locked gate"
)

static var GATE_UNLOCKED := Depths.new(
	"gate_unlocked", DangerLevel.CLEAR, Effects.EMPTY,
	"This gate has been opened and is now a safe depth.",
	1, "unlocked gate"
)

static var GATE_KEY := Depths.new(
	"gate_key", DangerLevel.CLEAR, Effects.GATE_UNLOCK,
	"Visiting this depth unlocks the gate, permanently disabling it."
)

#endregion

static var DO_NOT_EXHAUST: Array[Depths] = [
#	BASE,
	FINAL
]