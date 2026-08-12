extends Resource
## Contains the defined data collections for predefined pick cards
class_name PickTemplates

static func _get_texture(n: String) -> Resource:
	var res_str := "res://assets/picks/pick_%s.png" % [n]
	if ResourceLoader.exists(res_str):
		return load(res_str)
	else:
		return load("res://assets/picks/pick_debug_card.png")
	
## Human readable pick name, lowercase
var pick_name: String
## Pick effect dictionary. Type is dict[int, Array[EffectSpec]]
var effects: Dictionary[int, Array]
## Card art texture
var texture: Resource
## Pick description or flavortext (vestigial)
var description: String = ""
	
func _init(
	pick_name_: String,
	effects_: Dictionary[int, Array] = {},
	description_: String = "",
):
	pick_name = pick_name_
	description = description_
	effects = effects_
	texture = _get_texture(pick_name_)


static var DEBUG := PickTemplates.new(
	"debug", 
	{
		-1: [EffectSpec.new(Effects.REVEAL, 3)],
		0: [
			EffectSpec.new(Effects.PUSH, 4), 
			EffectSpec.new(Effects.TEST, 3),
			EffectSpec.new(Effects.REVEAL, 1)
		],
		2: [EffectSpec.new(Effects.DEBUG, 8)],
		3: [
			EffectSpec.new(Effects.JAM, 3),
			EffectSpec.new(Effects.DEBUG, 0)
		]
	},
	"If you see this, please tell starshine.",
)

#region RAKES

# Rakes affect many pins. 
# they typically have a mix of push and test but can have other types.
# the issues with rakes is they're both fragile and difficult 
# - lots of chances for break, and the test has so many hits if it returns danger 
# it's hard to use that directly

# push rakes are about capitalizing on good positioning / hint / jam to cash in a lot of
# push all at once (or just yoloing)
# test rakes are about getting a lot of information at once 
# - do I need to break this area down or is it clear?
# rakes are worse on later, more difficult levels
# (but this is balanced by a need for more total push, and their use as final yolo tools becomes
# more important in a larger deck with more income)

# rakes almost always have a bad 1: to make tipping less effective

# PUSH FOCUSED RAKES
# typically have peaks

static var TEN_PUSH_MONSTER_RAKE := PickTemplates.new(
	"pinnacle rake",
	{
		3: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
		],
		2: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 2),
		],
		1: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 2),
		],
		-1: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var EIGHT_PUSH_DEEP_BOMB_RAKE := PickTemplates.new(
	"jag rake",
	{
		2: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 2),
		],
		1: [EffectSpec.new(Effects.PUSH, 3)],
		0: [EffectSpec.new(Effects.PUSH, 3)],
		-1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 2),
		]
	}
)

static var TWO_ONE_FLAT_RAKE := PickTemplates.new(
	"four peak rake",
	{
		2: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
		],
		1: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
		],
		-1: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var FIVE_ACROSS_RAKE := PickTemplates.new(
	"stretched rake",
	{
		3: [EffectSpec.new(Effects.PUSH, 1)],
		2: [EffectSpec.new(Effects.PUSH, 1)],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		-1: [EffectSpec.new(Effects.PUSH, 1)]
	}
)

static var CRUSH_RAKE := PickTemplates.new(
	"spike rake",
	{
		3: [EffectSpec.new(Effects.CRUSH, 1)],
		2: [EffectSpec.new(Effects.CRUSH, 1)],
		1: [EffectSpec.new(Effects.CRUSH, 1)],
		0: [EffectSpec.new(Effects.CRUSH, 2)],
		-1: [EffectSpec.new(Effects.CRUSH, 1)]
	}
)

static var ALTERNATING_CRUSH_RAKE := PickTemplates.new(
	"rip rake",
	{
		2: [EffectSpec.new(Effects.CRUSH, 2)],
		1: [EffectSpec.new(Effects.PUSH, 1)],
		0: [EffectSpec.new(Effects.CRUSH, 2)],
		-1: [EffectSpec.new(Effects.PUSH, 1)]
	}
)

# TEST FOCUSED RAKES
# typically have wiggles and rolls

static var DARK_TEST_RAKE := PickTemplates.new(
	"camel rake",
	{
		2: [EffectSpec.new(Effects.PUSH, 1)],
		1: [EffectSpec.new(Effects.TEST, 2)],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 3),
		],
		-1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var EXTRA_DARK_TEST_RAKE := PickTemplates.new(
	"wave rake",
	{
		2: [EffectSpec.new(Effects.TEST, 2)],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 3),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 3),
		],
		-1: [EffectSpec.new(Effects.TEST, 2)]
	}
)

static var PUSHLESS_GAP_RAKE := PickTemplates.new(
	"city rake",
	{
		3: [
			EffectSpec.new(Effects.SKIP, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		2: [
			EffectSpec.new(Effects.SKIP, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		1: [
			EffectSpec.new(Effects.SKIP, 2),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.SKIP, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		-1: [
			EffectSpec.new(Effects.SKIP, 2),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

# semi-random gap rake
static var SCATTERED_GAP_RAKE := PickTemplates.new(
	"chatter rake",
	{
		2: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.SKIP, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.SKIP, 2),
			EffectSpec.new(Effects.TEST, 2),
		],
		-1: [
			EffectSpec.new(Effects.SKIP, 2),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var BROAD_PUSH_REVEAL_RAKE := PickTemplates.new(
	"snake rake",
	{
		3: [EffectSpec.new(Effects.PUSH, 1)],
		2: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.REVEAL, 1),
		],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.REVEAL, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.REVEAL, 1),
		],
		-1: [EffectSpec.new(Effects.PUSH, 1)]
	}
)

# has standard jam synergy
static var DEEP_REVEAL_RAKE := PickTemplates.new(
	"wyrm rake",
	{
		2: [EffectSpec.new(Effects.PUSH, 1)],
		1: [EffectSpec.new(Effects.PUSH, 2)],
		0: [EffectSpec.new(Effects.REVEAL, 3)],
		-1: [EffectSpec.new(Effects.PUSH, 2)]
	}
)

# hybrid
static var NOISY_FOUR_PUSH_RAKE := PickTemplates.new(
	"diamond rake",
	{
		3: [EffectSpec.new(Effects.TEST, 1)],
		2: [EffectSpec.new(Effects.TEST, 2)],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 2),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 2),
		],
		-1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var ONE_ONE_FLAT_RAKE := PickTemplates.new(
	"two peak rake",
	{
		2: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		-1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var ALTERNATING_RAKE := PickTemplates.new(
	"toothed rake",
	{
		3: [EffectSpec.new(Effects.TEST, 2)],
		2: [EffectSpec.new(Effects.PUSH, 2)],
		1: [EffectSpec.new(Effects.TEST, 2)],
		0: [EffectSpec.new(Effects.PUSH, 2)],
		-1: [EffectSpec.new(Effects.TEST, 2)]
	}
)

static var THREE_REVEAL_RAKE := PickTemplates.new(
	"worm rake",
	{
		3: [EffectSpec.new(Effects.REVEAL, 1)],
		2: [EffectSpec.new(Effects.REVEAL, 1)],
		1: [
			EffectSpec.new(Effects.REVEAL, 1),
			EffectSpec.new(Effects.PUSH, 1),
		],
		0: [EffectSpec.new(Effects.PUSH, 2)],
		-1: [EffectSpec.new(Effects.PUSH, 2)]
	}
)


# jam rakes
static var JAM_FLAVORED_PROBE_RAKE := PickTemplates.new(
	"broad rake",
	{
		2: [EffectSpec.new(Effects.TEST, 2)],
		1: [EffectSpec.new(Effects.TEST, 2)],
		0: [
			EffectSpec.new(Effects.TEST, 2),
			EffectSpec.new(Effects.JAM, 1),
		],
		-1: [EffectSpec.new(Effects.TEST, 1)]
	}
)

# close test with weird jam pattern
static var TEST_ACROSS_WITH_JAM_RAKE := PickTemplates.new(
	"spine rake",
	{
		3: [EffectSpec.new(Effects.TEST, 1)],
		2: [EffectSpec.new(Effects.TEST, 1)],
		1: [
			EffectSpec.new(Effects.JAM, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [EffectSpec.new(Effects.TEST, 1)],
		-1: [
			EffectSpec.new(Effects.JAM, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var PUSH_JAM_BLANKET_RAKE := PickTemplates.new(
	"blanket rake",
	{
		3: [EffectSpec.new(Effects.PUSH, 1)],
		2: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.JAM, 1),
		],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
			EffectSpec.new(Effects.JAM, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 2),
			EffectSpec.new(Effects.JAM, 1),
		]
	}
)

static var PUSH_JAM_RAKE := PickTemplates.new(
	"tension rake",
	{
		2: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.JAM, 1),
		],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.JAM, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 2),
		],
		-1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 2),
		]
	}
)
#endregion

#region DIAMONDS 
# affect a few pins, typically with one main pin and a few others
# designed to make up the core of a deck
# -1:s and even -2s do make them difficult, but they're still symbols
# (hooks are safe but weak (reminder: a 5 pin deck needs 40 push!))
# can have no 1: for tip purposes - this is the decider for flavors? (diamond / wedge)
# often have limited test

# PUSH FOCUSED
static var MEDIUM_FOUR_REACH_DIAMOND := PickTemplates.new(
	"large diamond",
	{
		2: [EffectSpec.new(Effects.TEST, 1)],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 3),
			EffectSpec.new(Effects.TEST, 1),
		],
		-1: [EffectSpec.new(Effects.PUSH, 1)]
	}
)

static var SMALL_THREE_REACH_DIAMOND := PickTemplates.new(
	"small diamond",
	{
		1: [EffectSpec.new(Effects.PUSH, 1)],
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var EIGHT_MOVEMENT_DEEP_DIAMOND := PickTemplates.new(
	"slice wedge",
	{
		2: [EffectSpec.new(Effects.PUSH, 1)],
		1: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.CRUSH, 1),
			EffectSpec.new(Effects.PUSH, 3),
			EffectSpec.new(Effects.TEST, 1),
		],
		-1: [EffectSpec.new(Effects.PUSH, 1)]
	}
)

# new default diamond?
static var TWO_FOUR_TWO_DIAMOND := PickTemplates.new(
	"quick diamond",
	{
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 2),
		],
		-1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var OFFSET_FINISHER_DIAMOND := PickTemplates.new(
	"offset wedge",
	{
		2: [EffectSpec.new(Effects.TEST, 1)],
		1: [EffectSpec.new(Effects.TEST, 2)],
		0: [EffectSpec.new(Effects.PUSH, 3)],
		-1: [EffectSpec.new(Effects.PUSH, 1)]
	}
)

static var REVEAL_DIAMOND := PickTemplates.new(
	"black diamond",
	{
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.REVEAL, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.REVEAL, 1),
		],
		-1: [EffectSpec.new(Effects.PUSH, 1)]
	}
)

# weird block (crush?) wedge
static var BLOCK_CRUSH_DIAMOND := PickTemplates.new(
	"block wedge",
	{
		2: [EffectSpec.new(Effects.TEST, 1)],
		1: [EffectSpec.new(Effects.CRUSH, 2)],
		0: [
			EffectSpec.new(Effects.CRUSH, 2),
			EffectSpec.new(Effects.TEST, 2),
		],
		-1: [EffectSpec.new(Effects.TEST, 1)]
	}
)

# block wedge
static var FLAT_BLOCK_DIAMOND := PickTemplates.new(
	"flattop",
	{
		2: [EffectSpec.new(Effects.PUSH, 1)],
		1: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 2),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 2),
		]
	}
)


# crushes
static var TRIANGLE_CRUSH_DIAMOND := PickTemplates.new(
	"bruiser wedge",
	{
		2: [EffectSpec.new(Effects.CRUSH, 1)],
		1: [EffectSpec.new(Effects.CRUSH, 2)],
		0: [EffectSpec.new(Effects.CRUSH, 3)]
	}
)

static var THREE_CRUSH_STACKED_DIAMOND := PickTemplates.new(
	"desert wedge",
	{
		2: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		1: [
			EffectSpec.new(Effects.CRUSH, 1),
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [EffectSpec.new(Effects.CRUSH, 3)],
		-1: [EffectSpec.new(Effects.PUSH, 1)]
	}
)

static var SPILLOVER_CRUSH := PickTemplates.new(
	"powder wedge",
	{
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.CRUSH, 2),
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

# test focused
static var SMALL_TEST_DIAMOND := PickTemplates.new(
	"soft wedge",
	{
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 2),
		]
	}
)

static var LARGE_TEST_DIAMOND := PickTemplates.new(
	"senses wedge",
	{
		2: [EffectSpec.new(Effects.PUSH, 1)],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 3),
		]
	}
)

static var FIVE_RANGE_PROBE_DIAMOND := PickTemplates.new(
	"false diamond",
	{
		2: [EffectSpec.new(Effects.PUSH, 1)],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.SKIP, 2),
			EffectSpec.new(Effects.TEST, 3),
		],
		-1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var THREE_REVEAL_DIAMOND := PickTemplates.new(
	"oracle wedge",
	{
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.REVEAL, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.REVEAL, 2),
		]
	}
)

static var PUSH_TEST_REVEAL_DIAMOND := PickTemplates.new(
	"perfect diamond",
	{
		2: [EffectSpec.new(Effects.PUSH, 1)],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.REVEAL, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		-1: [EffectSpec.new(Effects.TEST, 1)]
	}
)


# jam flavored
static var THREE_FOUR_JAM_FINISHER := PickTemplates.new(
	"curse diamond",
	{
		0: [
			EffectSpec.new(Effects.PUSH, 3),
			EffectSpec.new(Effects.JAM, 2),
		],
		-1: [EffectSpec.new(Effects.JAM, 2)]
	}
)

static var BLEND_JAM_DIAMOND := PickTemplates.new(
	"twist wedge",
	{
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
			EffectSpec.new(Effects.JAM, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
			EffectSpec.new(Effects.JAM, 1),
		]
	}
)
#endregion

#region HOOKS
# affects a single pin, but rarely has significant movement

# invincible but questionable deck slot
static var TINY_HOOK := PickTemplates.new(
	"tiny hook",
	{
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

# exceptionally situational but invincible
static var ONE_REVEAL_HOOK := PickTemplates.new(
	"wire hook",
	{
		0: [EffectSpec.new(Effects.REVEAL, 1)]
	}
)

# single target diffuser
static var SKIP_TEST_DIFFUSER_HOOK := PickTemplates.new(
	"trap hook",
	{
		0: [
			EffectSpec.new(Effects.SKIP, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

# push focused
static var CLASSIC_HOOK := PickTemplates.new(
	"classic hook",
	{
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 2),
		]
	}
)

static var PUSH_REVEAL_HOOK := PickTemplates.new(
	"feeler hook",
	{
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.REVEAL, 1),
		]
	}
)

# jam hook
static var CRUSH_JAM_HOOK := PickTemplates.new(
	"crook",
	{
		0: [
			EffectSpec.new(Effects.CRUSH, 2),
			EffectSpec.new(Effects.TEST, 1),
			EffectSpec.new(Effects.JAM, 1),
		]
	}
)

# two into three combo hook
static var FIVE_DEEP_SINGLE_HOOK := PickTemplates.new(
	"wary hook",
	{
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.SKIP, 2),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var BONUS_REVEAL_HOOK := PickTemplates.new(
	"hat hook",
	{
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.SKIP, 3),
			EffectSpec.new(Effects.REVEAL, 1),
		]
	}
)

# test focused

# good test hook with a dependency
static var DEPENDENCY_HOOK := PickTemplates.new(
	"canted hook",
	{
		1: [EffectSpec.new(Effects.PUSH, 1)],
		0: [
			EffectSpec.new(Effects.REVEAL, 1),
			EffectSpec.new(Effects.TEST, 2),
		]
	}
)

# awkwardly deep test hook
static var FOUR_DARK_HOOK := PickTemplates.new(
	"shepard hook",
	{
		0: [
			EffectSpec.new(Effects.SKIP, 1),
			EffectSpec.new(Effects.TEST, 4),
		]
	}
)

static var SKIP_TEST_HOOK := PickTemplates.new(
	"guide hook",
	{
		0: [
			EffectSpec.new(Effects.SKIP, 2),
			EffectSpec.new(Effects.TEST, 2),
		]
	}
)

# more limited deep test
static var FIVE_DARK_HOOK := PickTemplates.new(
	"pirate hook",
	{
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.SKIP, 1),
			EffectSpec.new(Effects.TEST, 3),
		]
	}
)

# super deep test
static var SIX_DARK_GONZO_HOOK := PickTemplates.new(
	"gonzo hook",
	{
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.SKIP, 2),
			EffectSpec.new(Effects.TEST, 2),
		]
	}
)

static var THREE_TEST_HOOK := PickTemplates.new(
	"spring hook",
	{
		0: [EffectSpec.new(Effects.TEST, 3)]
	}
)

# crush flavored

# standard crush
static var THREE_STACK_CRUSH := PickTemplates.new(
	"lever",
	{
		0: [EffectSpec.new(Effects.CRUSH, 3)]
	}
)

static var PUSH_CRUSH := PickTemplates.new(
	"prybar",
	{
		0: [
			EffectSpec.new(Effects.CRUSH, 2),
			EffectSpec.new(Effects.PUSH, 2),
		]
	}
)
#endregion

#region JAMS
# used for tricks and safekeeping

static var ONE_TWO_JAM := PickTemplates.new(
	"standard wrench",
	{
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.JAM, 1),
		],
		0: [EffectSpec.new(Effects.JAM, 2)]
	}
)

static var FOUR_TWO_JAM := PickTemplates.new(
	"monster wrench",
	{
		1: [EffectSpec.new(Effects.JAM, 4)],
		0: [
			EffectSpec.new(Effects.TEST, 2),
			EffectSpec.new(Effects.JAM, 2),
		]
	}
)

static var TWO_TWO_BLOCK_JAM := PickTemplates.new(
	"column wrench",
	{
		1: [EffectSpec.new(Effects.JAM, 2)],
		0: [EffectSpec.new(Effects.JAM, 2)],
		-1: [EffectSpec.new(Effects.PUSH, 1)]
	}
)

static var ISOLATION_SHELF_JAM := PickTemplates.new(
	"shelf wrench",
	{
		3: [EffectSpec.new(Effects.JAM, 2)],
		2: [EffectSpec.new(Effects.JAM, 1)],
		1: [EffectSpec.new(Effects.JAM, 1)],
		0: [EffectSpec.new(Effects.TEST, 1)],
		-1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

# very light trick jam
static var TWO_TEST_JAM := PickTemplates.new(
	"trick wrench",
	{
		0: [
			EffectSpec.new(Effects.TEST, 2),
			EffectSpec.new(Effects.JAM, 1),
		]
	}
)

static var COMPLETION_JAM := PickTemplates.new(
	"table wrench",
	{
		3: [EffectSpec.new(Effects.PUSH, 1)],
		2: [EffectSpec.new(Effects.JAM, 1)],
		1: [EffectSpec.new(Effects.JAM, 2)],
		0: [EffectSpec.new(Effects.JAM, 1)],
		-1: [EffectSpec.new(Effects.PUSH, 1)]
	}
)

# single pin jam with strange offset
static var NARROW_THREE_JAM := PickTemplates.new(
	"narrow wrench",
	{
		0: [EffectSpec.new(Effects.TEST, 1)],
		-1: [EffectSpec.new(Effects.JAM, 3)]
	}
)

static var FOCUS_LENS_JAM := PickTemplates.new(
	"focus wrench",
	{
		3: [EffectSpec.new(Effects.JAM, 1)],
		2: [EffectSpec.new(Effects.JAM, 1)],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		-1: [EffectSpec.new(Effects.JAM, 1)]
	}
)

static var COLUMN_LOCKDOWN_JAM := PickTemplates.new(
	"lockup wrench",
	{
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [EffectSpec.new(Effects.JAM, 3)],
		-1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var TWO_THREE_JAM := PickTemplates.new(
	"heavy wrench",
	{
		1: [EffectSpec.new(Effects.JAM, 2)],
		0: [EffectSpec.new(Effects.JAM, 3)]
	}
)

static var ONE_ONLY_JAM := PickTemplates.new(
	"feather wrench",
	{
		0: [EffectSpec.new(Effects.JAM, 1)]
	}
)


# weird
static var CRUSH_JAM := PickTemplates.new(
	"mangler",
	{
		1: [
			EffectSpec.new(Effects.CRUSH, 1),
			EffectSpec.new(Effects.JAM, 1),
		],
		0: [
			EffectSpec.new(Effects.CRUSH, 2),
			EffectSpec.new(Effects.JAM, 1),
		],
		-1: [
			EffectSpec.new(Effects.CRUSH, 1),
			EffectSpec.new(Effects.JAM, 1),
		]
	}
)

static var FORK_JAM := PickTemplates.new(
	"fork",
	{
		1: [
			EffectSpec.new(Effects.TEST, 2),
			EffectSpec.new(Effects.JAM, 1),
		],
		0: [EffectSpec.new(Effects.PUSH, 1)],
		-1: [
			EffectSpec.new(Effects.TEST, 2),
			EffectSpec.new(Effects.JAM, 1),
		]
	}
)

static var REVEAL_JAM := PickTemplates.new(
	"workshop wrench",
	{
		1: [EffectSpec.new(Effects.PUSH, 1)],
		0: [
			EffectSpec.new(Effects.REVEAL, 1),
			EffectSpec.new(Effects.JAM, 3),
		]
	}
)
#endregion


#region special use picks

static var NEEDLE := PickTemplates.new(
	"needle",
	{
		2: [EffectSpec.new(Effects.TEST, 1)],
		1: [EffectSpec.new(Effects.TEST, 2)],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 2),
		]
	}
)

static var NAIL := PickTemplates.new(
	"nail",
	{
		1: [
			EffectSpec.new(Effects.CRUSH, 2),
			EffectSpec.new(Effects.JAM, 3)
		],
		0: [
			EffectSpec.new(Effects.CRUSH, 2),
			EffectSpec.new(Effects.JAM, 3)
		]
	}
)

static var FISHHOOK := PickTemplates.new(
	"fishhook",
	{
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.SKIP, 1),
			EffectSpec.new(Effects.REVEAL, 1),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var HAIRPIN := PickTemplates.new(
	"hairpin",
	{
		2: [EffectSpec.new(Effects.PUSH, 2)],
		1: [EffectSpec.new(Effects.PUSH, 2)],
		0: [EffectSpec.new(Effects.PUSH, 2)],
		-1: [EffectSpec.new(Effects.JAM, 2)],
	}
)

static var TOOTHPICK := PickTemplates.new(
	"toothpick",
	{
		2: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1)
		],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1)
		],
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 1)
		],
		-1: [EffectSpec.new(Effects.PUSH, 1)],
	}
)

static var OLD_KEY := PickTemplates.new(
	"old key",
	{
		1: [EffectSpec.new(Effects.PUSH, 3)],
		0: [EffectSpec.new(Effects.JAM, 3)],
		-1: [EffectSpec.new(Effects.PUSH, 3)],
	}
)
#endregion

static var valid_templates: Array[PickTemplates] = [
	# push rakes
	TEN_PUSH_MONSTER_RAKE, ###
	EIGHT_PUSH_DEEP_BOMB_RAKE, ###
	TWO_ONE_FLAT_RAKE, ##
	FIVE_ACROSS_RAKE, #
	CRUSH_RAKE, ###
	ALTERNATING_CRUSH_RAKE, ##
	# test rakes
	DARK_TEST_RAKE, ##
	EXTRA_DARK_TEST_RAKE, ##
	PUSHLESS_GAP_RAKE, ##
	SCATTERED_GAP_RAKE, ###
	BROAD_PUSH_REVEAL_RAKE, ##
	DEEP_REVEAL_RAKE, ###
	# hybrid rakes
	NOISY_FOUR_PUSH_RAKE, #
	ONE_ONE_FLAT_RAKE, #
	ALTERNATING_RAKE, ##
	THREE_REVEAL_RAKE, ##  - precision deck icon
	# jam rakes
	JAM_FLAVORED_PROBE_RAKE, ##
	TEST_ACROSS_WITH_JAM_RAKE, #
	PUSH_JAM_BLANKET_RAKE, ###
	PUSH_JAM_RAKE, ##
	# push diamonds
	MEDIUM_FOUR_REACH_DIAMOND, #
	SMALL_THREE_REACH_DIAMOND, ##
	EIGHT_MOVEMENT_DEEP_DIAMOND, ###
	TWO_FOUR_TWO_DIAMOND, #
	OFFSET_FINISHER_DIAMOND, ##
	REVEAL_DIAMOND, ###
	# crush diamonds
	BLOCK_CRUSH_DIAMOND, ###
	FLAT_BLOCK_DIAMOND, ##
	TRIANGLE_CRUSH_DIAMOND, ##
	THREE_CRUSH_STACKED_DIAMOND, ###
	SPILLOVER_CRUSH, ###
	# test diamonds
	SMALL_TEST_DIAMOND, ##
	LARGE_TEST_DIAMOND, #
	FIVE_RANGE_PROBE_DIAMOND, ###
	THREE_REVEAL_DIAMOND, ##
	PUSH_TEST_REVEAL_DIAMOND, ###
	# jam diamonds
	THREE_FOUR_JAM_FINISHER, ###
	BLEND_JAM_DIAMOND, ###
	# small hooks
	TINY_HOOK, ##
	ONE_REVEAL_HOOK, ##
	SKIP_TEST_DIFFUSER_HOOK, ##
	# push hooks
	CLASSIC_HOOK, #
	PUSH_REVEAL_HOOK, ##
	CRUSH_JAM_HOOK, ##
	FIVE_DEEP_SINGLE_HOOK, ##
	BONUS_REVEAL_HOOK, ##
	# test hooks
	DEPENDENCY_HOOK, ##
	FOUR_DARK_HOOK, ##
	SKIP_TEST_HOOK, #
	FIVE_DARK_HOOK, ###
	SIX_DARK_GONZO_HOOK, ###
	THREE_TEST_HOOK, ##
	# crush hooks
	THREE_STACK_CRUSH, #
	PUSH_CRUSH, ##
	# jams
	ONE_TWO_JAM, #
	FOUR_TWO_JAM, ###
	TWO_TWO_BLOCK_JAM, ##
	ISOLATION_SHELF_JAM, ###
	TWO_TEST_JAM, ##
	COMPLETION_JAM, ###
	NARROW_THREE_JAM, ##
	FOCUS_LENS_JAM, ##
	COLUMN_LOCKDOWN_JAM, ##
	TWO_THREE_JAM, ##
	ONE_ONLY_JAM, ###
	CRUSH_JAM, ##
	FORK_JAM, #
	REVEAL_JAM, ###
]

static var temporary_picks: Array[PickTemplates] = [
	NEEDLE,
	NAIL,
	FISHHOOK,
	HAIRPIN,
	TOOTHPICK,
	OLD_KEY,
]