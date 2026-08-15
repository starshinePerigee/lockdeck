extends Resource
## Contains the defined data collections for predefined pick cards
class_name PickTemplates

enum Families {
	NONE,
	RAKE,
	DIAMOND,
	HOOK,
	WRENCH,
}

enum Archetypes {
	WEIRD,
	BULK_PUSH,
	BULK_TEST,
	HYBRID_S,
	GAPS,
	DARK,
	THREE_PUSH,
	FINISHER,
	REVEAL,
	PRECISE,
	PUSHY,
	JUMP_TEST,
	CLOSE_TEST,
	END_TURN,
	LOCK_N_BLOCK,
	ISOLATION,
	TRICKS
}

enum Rarities {
	DEBUG = -1,
	BASIC = 3,
	GREAT = 5,
	TRASH = 1,
	COMMON = 2,
	RARE = 4,
	TEMPORARY = 0,
}

static func _get_texture(n: String) -> Resource:
	var res_str := "res://assets/picks/pick_%s.png" % [n]
	if ResourceLoader.exists(res_str):
		return load(res_str)
	else:
		return load("res://assets/picks/pick_debug_card.png")
	
## Human readable pick name, lowercase
var pick_name: String

## pick metadata
var family: Families
var archetype: Archetypes
var rarity: Rarities

## Pick effect dictionary. Type is dict[int, Array[EffectSpec]]
var effects: Dictionary[int, Array]
## Card art texture
var texture: Resource

static func parse_effect_substring(substring: String) -> Array[EffectSpec]:
	var sub_effects: Array[EffectSpec] = []
	
	var effect_count := {
		"P": 0,
		".": 0,
		"T": 0,
		"R": 0,
		"J": 0,
	}
	
	for chr in substring:
		effect_count[chr] += 1
	
	for e in effect_count.keys():
		if effect_count[e] > 0:
			var effect := Effects.DEBUG 
			match e:
				"P": effect = Effects.PUSH
				".": effect = Effects.SKIP
				"T": effect = Effects.TEST
				"R": effect = Effects.REVEAL
				"J": effect = Effects.JAM
			sub_effects.append(EffectSpec.new(effect, effect_count[e]))
	
	return sub_effects

static func parse_effects_string(effect_string: String) -> Dictionary[int, Array]:
	var new_effects: Dictionary[int, Array] = {}
	if effect_string.contains("]"):
		var tip_split: PackedStringArray = effect_string.split("]")
		effect_string = tip_split[0]
		new_effects[-1] = parse_effect_substring(tip_split[1])
	
	var main_split: PackedStringArray = effect_string.split("[")
	for i in len(main_split):
		new_effects[i] = parse_effect_substring(
			main_split[len(main_split) - i - 1]
		)
	
	return new_effects

func _init(
	pick_name_: String,
	family_: Families,
	archetype_: Archetypes,
	rarity_: Rarities,
	effect_string: String,
):
	pick_name = pick_name_
	family = family_
	archetype = archetype_
	rarity = rarity_
	effects = parse_effects_string(effect_string)
	texture = _get_texture(pick_name_)


## JJJ/DDDDDDDD/PPPPTTTR\RRR
static var DEBUG := PickTemplates.new(
	"debug", 
	Families.NONE,
	Archetypes.WEIRD,
	Rarities.DEBUG,
	"JJJ[........[PPPPTTTR]RRR"
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

## PPT[PPT[PPT]PPT
static var RAKE_BULK_PUSH_BASIC := PickTemplates.new(
	"four peak rake",
	Families.RAKE,
	Archetypes.BULK_PUSH,
	Rarities.BASIC,
	"PPT[PPT[PPT]PPT"
)

## PPTT[PPTT[PPTT[PPPR]PPPR
static var RAKE_BULK_PUSH_GREAT := PickTemplates.new(
	"pinnacle",
	Families.RAKE,
	Archetypes.BULK_PUSH,
	Rarities.GREAT,
	"PPTT[PPTT[PPTT[PPPR]PPPR"
)

## PP[P[PP[PP]PP
static var RAKE_BULK_PUSH_TRASH := PickTemplates.new(
	"spine",
	Families.RAKE,
	Archetypes.BULK_PUSH,
	Rarities.TRASH,
	"PP[P[PP[PP]PP"
)

## PPT[PPTT[PPT[PPTT]PPT
static var RAKE_BULK_PUSH_COMMON := PickTemplates.new(
	"five peaks",
	Families.RAKE,
	Archetypes.BULK_PUSH,
	Rarities.COMMON,
	"PPT[PPTT[PPT[PPTT]PPT"
)

## TT[PPP[TT[PPP]TT
static var RAKE_BULK_PUSH_RARE := PickTemplates.new(
	"toothy",
	Families.RAKE,
	Archetypes.BULK_PUSH,
	Rarities.RARE,
	"TT[PPP[TT[PPP]TT"
)

## TT[TT[TTTJ]T
static var RAKE_BULK_TEST_BASIC := PickTemplates.new(
	"snake rake",
	Families.RAKE,
	Archetypes.BULK_TEST,
	Rarities.BASIC,
	"TT[TT[TTTJ]T"
)

## TT[TT[RR[PPRR]TT
static var RAKE_BULK_TEST_GREAT := PickTemplates.new(
	"wyrm",
	Families.RAKE,
	Archetypes.BULK_TEST,
	Rarities.GREAT,
	"TT[TT[RR[PPRR]TT"
)

## TTT[PTT[PTT]TTT
static var RAKE_BULK_TEST_TRASH := PickTemplates.new(
	"wave",
	Families.RAKE,
	Archetypes.BULK_TEST,
	Rarities.TRASH,
	"TTT[PTT[PTT]TTT"
)

## TT[PTTT[PTTT
static var RAKE_BULK_TEST_COMMON := PickTemplates.new(
	"curl rake",
	Families.RAKE,
	Archetypes.BULK_TEST,
	Rarities.COMMON,
	"TT[PTTT[PTTT"
)

## PJ[PJ[PTT]PTT
static var RAKE_BULK_TEST_RARE := PickTemplates.new(
	"twist",
	Families.RAKE,
	Archetypes.BULK_TEST,
	Rarities.RARE,
	"PJ[PJ[PTT]PTT"
)

## PT[PT[PR]PT
static var RAKE_HYBRID_S_BASIC := PickTemplates.new(
	"city rake",
	Families.RAKE,
	Archetypes.HYBRID_S,
	Rarities.BASIC,
	"PT[PT[PR]PT"
)

## PT[PR[PT[PRT]RT
static var RAKE_HYBRID_S_GREAT := PickTemplates.new(
	"blanket",
	Families.RAKE,
	Archetypes.HYBRID_S,
	Rarities.GREAT,
	"PT[PR[PT[PRT]RT"
)

## T[T[P[P]T
static var RAKE_HYBRID_S_TRASH := PickTemplates.new(
	"camel",
	Families.RAKE,
	Archetypes.HYBRID_S,
	Rarities.TRASH,
	"T[T[P[P]T"
)

## P[P[PT[PT]P
static var RAKE_HYBRID_S_COMMON := PickTemplates.new(
	"broad rake",
	Families.RAKE,
	Archetypes.HYBRID_S,
	Rarities.COMMON,
	"P[P[PT[PT]P"
)

## P[TT[PTTT]PT
static var RAKE_HYBRID_S_RARE := PickTemplates.new(
	"spike",
	Families.RAKE,
	Archetypes.HYBRID_S,
	Rarities.RARE,
	"P[TT[PTTT]PT"
)

## P.T[P.T[P.T]P.T
static var RAKE_GAPS_BASIC := PickTemplates.new(
	"gap rake",
	Families.RAKE,
	Archetypes.GAPS,
	Rarities.BASIC,
	"P.T[P.T[P.T]P.T"
)

## P.RT[P.RT[P.RT]P.RT
static var RAKE_GAPS_GREAT := PickTemplates.new(
	"oracle",
	Families.RAKE,
	Archetypes.GAPS,
	Rarities.GREAT,
	"P.RT[P.RT[P.RT]P.RT"
)

## .T[..T[.T]..T
static var RAKE_GAPS_TRASH := PickTemplates.new(
	"chatter",
	Families.RAKE,
	Archetypes.GAPS,
	Rarities.TRASH,
	".T[..T[.T]..T"
)

## P.TT[P.RR]P.TT
static var RAKE_GAPS_COMMON := PickTemplates.new(
	"pop rake",
	Families.RAKE,
	Archetypes.GAPS,
	Rarities.COMMON,
	"P.TT[P.RR]P.TT"
)

## P.T[PT[P..TT]..T
static var RAKE_GAPS_RARE := PickTemplates.new(
	"wanderer",
	Families.RAKE,
	Archetypes.GAPS,
	Rarities.RARE,
	"P.T[PT[P..TT]..T"
)
#endregion

#region DIAMONDS 
# affect a few pins, typically with one main pin and a few others
# designed to make up the core of a deck
# -1:s and even -2s do make them difficult, but they're still symbols
# (hooks are safe but weak (reminder: a 5 pin deck needs 40 push!))
# can have no 1: for tip purposes - this is the decider for flavors? (diamond / wedge)
# often have limited test

## PP[PPPP
static var DIAMOND_DARK_BASIC := PickTemplates.new(
	"offset diamond",
	Families.DIAMOND,
	Archetypes.DARK,
	Rarities.BASIC,
	"PP[PPPP"
)

## PT[PPTT[PPPPJ
static var DIAMOND_DARK_GREAT := PickTemplates.new(
	"black diamond",
	Families.DIAMOND,
	Archetypes.DARK,
	Rarities.GREAT,
	"PT[PPTT[PPPPJ"
)

## PPJ[P[PPPP]P
static var DIAMOND_DARK_TRASH := PickTemplates.new(
	"soul gem",
	Families.DIAMOND,
	Archetypes.DARK,
	Rarities.TRASH,
	"PPJ[P[PPPP]P"
)

## P[PPT[PPPP]PT
static var DIAMOND_DARK_COMMON := PickTemplates.new(
	"full diamond",
	Families.DIAMOND,
	Archetypes.DARK,
	Rarities.COMMON,
	"P[PPT[PPPP]PT"
)

## PTT[PPPP[PPPP]PTT
static var DIAMOND_DARK_RARE := PickTemplates.new(
	"block diamond",
	Families.DIAMOND,
	Archetypes.DARK,
	Rarities.RARE,
	"PTT[PPPP[PPPP]PTT"
)

## PT[PPT[PPPT
static var DIAMOND_THREE_PUSH_BASIC := PickTemplates.new(
	"half diamond",
	Families.DIAMOND,
	Archetypes.THREE_PUSH,
	Rarities.BASIC,
	"PT[PPT[PPPT"
)

## PTT[PPPTT
static var DIAMOND_THREE_PUSH_GREAT := PickTemplates.new(
	"perfect diamond",
	Families.DIAMOND,
	Archetypes.THREE_PUSH,
	Rarities.GREAT,
	"PTT[PPPTT"
)

## P[PP[PPP]P
static var DIAMOND_THREE_PUSH_TRASH := PickTemplates.new(
	"rough gem",
	Families.DIAMOND,
	Archetypes.THREE_PUSH,
	Rarities.TRASH,
	"P[PP[PPP]P"
)

## T[TT[PPP]P
static var DIAMOND_THREE_PUSH_COMMON := PickTemplates.new(
	"small diamond",
	Families.DIAMOND,
	Archetypes.THREE_PUSH,
	Rarities.COMMON,
	"T[TT[PPP]P"
)

## PTT[PPJ[PPPTTT]P
static var DIAMOND_THREE_PUSH_RARE := PickTemplates.new(
	"lost diamond",
	Families.DIAMOND,
	Archetypes.THREE_PUSH,
	Rarities.RARE,
	"PTT[PPJ[PPPTTT]P"
)

## PTT[PPJJ]JJ
static var DIAMOND_FINISHER_BASIC := PickTemplates.new(
	"finisher",
	Families.DIAMOND,
	Archetypes.FINISHER,
	Rarities.BASIC,
	"PTT[PPJJ]JJ"
)

## T[PTT[PPPJJ]J
static var DIAMOND_FINISHER_GREAT := PickTemplates.new(
	"getaway",
	Families.DIAMOND,
	Archetypes.FINISHER,
	Rarities.GREAT,
	"T[PTT[PPPJJ]J"
)

## PPJ[PPPJ
static var DIAMOND_FINISHER_TRASH := PickTemplates.new(
	"curse wedge",
	Families.DIAMOND,
	Archetypes.FINISHER,
	Rarities.TRASH,
	"PPJ[PPPJ"
)

## P[PPJJ
static var DIAMOND_FINISHER_COMMON := PickTemplates.new(
	"desert wedge",
	Families.DIAMOND,
	Archetypes.FINISHER,
	Rarities.COMMON,
	"P[PPJJ"
)

## TT[PPPJJ]JJ
static var DIAMOND_FINISHER_RARE := PickTemplates.new(
	"biter",
	Families.DIAMOND,
	Archetypes.FINISHER,
	Rarities.RARE,
	"TT[PPPJJ]JJ"
)

## PR[PRR
static var DIAMOND_REVEAL_BASIC := PickTemplates.new(
	"feeler wedge",
	Families.DIAMOND,
	Archetypes.REVEAL,
	Rarities.BASIC,
	"PR[PRR"
)

## PR[P.R[PP.RR
static var DIAMOND_REVEAL_GREAT := PickTemplates.new(
	"sense wedge",
	Families.DIAMOND,
	Archetypes.REVEAL,
	Rarities.GREAT,
	"PR[P.R[PP.RR"
)

## P[RT]P
static var DIAMOND_REVEAL_TRASH := PickTemplates.new(
	"false diamond",
	Families.DIAMOND,
	Archetypes.REVEAL,
	Rarities.TRASH,
	"P[RT]P"
)

## R[R[RP[PP]PP
static var DIAMOND_REVEAL_COMMON := PickTemplates.new(
	"drag wedge",
	Families.DIAMOND,
	Archetypes.REVEAL,
	Rarities.COMMON,
	"R[R[RP[PP]PP"
)

## P[PP[RRR]P
static var DIAMOND_REVEAL_RARE := PickTemplates.new(
	"hollow diamond",
	Families.DIAMOND,
	Archetypes.REVEAL,
	Rarities.RARE,
	"P[PP[RRR]P"
)

#endregion

#region HOOKS
# affects a single pin, but rarely has significant movement

## PT
static var HOOK_PRECISE_BASIC := PickTemplates.new(
	"short hook",
	Families.HOOK,
	Archetypes.PRECISE,
	Rarities.BASIC,
	"PT"
)

## PRT
static var HOOK_PRECISE_GREAT := PickTemplates.new(
	"crescent hook",
	Families.HOOK,
	Archetypes.PRECISE,
	Rarities.GREAT,
	"PRT"
)

## P
static var HOOK_PRECISE_TRASH := PickTemplates.new(
	"tiny",
	Families.HOOK,
	Archetypes.PRECISE,
	Rarities.TRASH,
	"P"
)

## T[PTT
static var HOOK_PRECISE_COMMON := PickTemplates.new(
	"scooped hook",
	Families.HOOK,
	Archetypes.PRECISE,
	Rarities.COMMON,
	"T[PTT"
)

## P.RTJ
static var HOOK_PRECISE_RARE := PickTemplates.new(
	"spring hook",
	Families.HOOK,
	Archetypes.PRECISE,
	Rarities.RARE,
	"P.RTJ"
)

## PPTTT
static var HOOK_PUSHY_BASIC := PickTemplates.new(
	"classic hook",
	Families.HOOK,
	Archetypes.PUSHY,
	Rarities.BASIC,
	"PPTTT"
)

## PPP.TT
static var HOOK_PUSHY_GREAT := PickTemplates.new(
	"gonzo hook",
	Families.HOOK,
	Archetypes.PUSHY,
	Rarities.GREAT,
	"PPP.TT"
)

## PP..T
static var HOOK_PUSHY_TRASH := PickTemplates.new(
	"crook",
	Families.HOOK,
	Archetypes.PUSHY,
	Rarities.TRASH,
	"PP..T"
)

## PPP
static var HOOK_PUSHY_COMMON := PickTemplates.new(
	"prybar",
	Families.HOOK,
	Archetypes.PUSHY,
	Rarities.COMMON,
	"PPP"
)

## PP.R
static var HOOK_PUSHY_RARE := PickTemplates.new(
	"pirate's hook",
	Families.HOOK,
	Archetypes.PUSHY,
	Rarities.RARE,
	"PP.R"
)

## P.TTT
static var HOOK_JUMP_TEST_BASIC := PickTemplates.new(
	"jump hook",
	Families.HOOK,
	Archetypes.JUMP_TEST,
	Rarities.BASIC,
	"P.TTT"
)

## ..RRTT
static var HOOK_JUMP_TEST_GREAT := PickTemplates.new(
	"moon hook",
	Families.HOOK,
	Archetypes.JUMP_TEST,
	Rarities.GREAT,
	"..RRTT"
)

## .T
static var HOOK_JUMP_TEST_TRASH := PickTemplates.new(
	"tap",
	Families.HOOK,
	Archetypes.JUMP_TEST,
	Rarities.TRASH,
	".T"
)

## .TTTT
static var HOOK_JUMP_TEST_COMMON := PickTemplates.new(
	"bend",
	Families.HOOK,
	Archetypes.JUMP_TEST,
	Rarities.COMMON,
	".TTTT"
)

## PP..TT
static var HOOK_JUMP_TEST_RARE := PickTemplates.new(
	"hat hook",
	Families.HOOK,
	Archetypes.JUMP_TEST,
	Rarities.RARE,
	"PP..TT"
)

## TTT
static var HOOK_CLOSE_TEST_BASIC := PickTemplates.new(
	"trap hook",
	Families.HOOK,
	Archetypes.CLOSE_TEST,
	Rarities.BASIC,
	"TTT"
)

## RRTTT
static var HOOK_CLOSE_TEST_GREAT := PickTemplates.new(
	"guide hook",
	Families.HOOK,
	Archetypes.CLOSE_TEST,
	Rarities.GREAT,
	"RRTTT"
)

## R
static var HOOK_CLOSE_TEST_TRASH := PickTemplates.new(
	"wire hook",
	Families.HOOK,
	Archetypes.CLOSE_TEST,
	Rarities.TRASH,
	"R"
)

## P[RTTT
static var HOOK_CLOSE_TEST_COMMON := PickTemplates.new(
	"crabclaw",
	Families.HOOK,
	Archetypes.CLOSE_TEST,
	Rarities.COMMON,
	"P[RTTT"
)

## TTT[.TTT
static var HOOK_CLOSE_TEST_RARE := PickTemplates.new(
	"shepard's hook",
	Families.HOOK,
	Archetypes.CLOSE_TEST,
	Rarities.RARE,
	"TTT[.TTT"
)

#endregion

#region JAMS
# used for tricks and safekeeping

## J[JJ
static var WRENCH_END_TURN_BASIC := PickTemplates.new(
	"basic wrench",
	Families.WRENCH,
	Archetypes.END_TURN,
	Rarities.BASIC,
	"J[JJ"
)

## JJ[JJ]JJ
static var WRENCH_END_TURN_GREAT := PickTemplates.new(
	"rib bone",
	Families.WRENCH,
	Archetypes.END_TURN,
	Rarities.GREAT,
	"JJ[JJ]JJ"
)

## PJ[PJ
static var WRENCH_END_TURN_TRASH := PickTemplates.new(
	"table wrench",
	Families.WRENCH,
	Archetypes.END_TURN,
	Rarities.TRASH,
	"PJ[PJ"
)

## T[T[TJ[T]TJ
static var WRENCH_END_TURN_COMMON := PickTemplates.new(
	"top wrench",
	Families.WRENCH,
	Archetypes.END_TURN,
	Rarities.COMMON,
	"T[T[TJ[T]TJ"
)

## P[PJ[PTJ[PTTJ
static var WRENCH_END_TURN_RARE := PickTemplates.new(
	"workshop wrench",
	Families.WRENCH,
	Archetypes.END_TURN,
	Rarities.RARE,
	"P[PJ[PTJ[PTTJ"
)

## JJJJ[TTJJ
static var WRENCH_LOCK_N_BLOCK_BASIC := PickTemplates.new(
	"lock n' block",
	Families.WRENCH,
	Archetypes.LOCK_N_BLOCK,
	Rarities.BASIC,
	"JJJJ[TTJJ"
)

## JJJJJ
static var WRENCH_LOCK_N_BLOCK_GREAT := PickTemplates.new(
	"monster wrench",
	Families.WRENCH,
	Archetypes.LOCK_N_BLOCK,
	Rarities.GREAT,
	"JJJJJ"
)

## P[PJJ]P
static var WRENCH_LOCK_N_BLOCK_TRASH := PickTemplates.new(
	"mangler",
	Families.WRENCH,
	Archetypes.LOCK_N_BLOCK,
	Rarities.TRASH,
	"P[PJJ]P"
)

## P[JJJ
static var WRENCH_LOCK_N_BLOCK_COMMON := PickTemplates.new(
	"canted wrench",
	Families.WRENCH,
	Archetypes.LOCK_N_BLOCK,
	Rarities.COMMON,
	"P[JJJ"
)

## PT[JJJ]PT
static var WRENCH_LOCK_N_BLOCK_RARE := PickTemplates.new(
	"valley wrench",
	Families.WRENCH,
	Archetypes.LOCK_N_BLOCK,
	Rarities.RARE,
	"PT[JJJ]PT"
)

## TTJ[P]TTJ
static var WRENCH_ISOLATION_BASIC := PickTemplates.new(
	"fork",
	Families.WRENCH,
	Archetypes.ISOLATION,
	Rarities.BASIC,
	"TTJ[P]TTJ"
)

## J[J[JJ[RTT]JJ
static var WRENCH_ISOLATION_GREAT := PickTemplates.new(
	"shadow",
	Families.WRENCH,
	Archetypes.ISOLATION,
	Rarities.GREAT,
	"J[J[JJ[RTT]JJ"
)

## JJ[P
static var WRENCH_ISOLATION_TRASH := PickTemplates.new(
	"dog ear",
	Families.WRENCH,
	Archetypes.ISOLATION,
	Rarities.TRASH,
	"JJ[P"
)

## J[J[PT[PT]J
static var WRENCH_ISOLATION_COMMON := PickTemplates.new(
	"focus wrench",
	Families.WRENCH,
	Archetypes.ISOLATION,
	Rarities.COMMON,
	"J[J[PT[PT]J"
)

## JJ[J[J[T]PT
static var WRENCH_ISOLATION_RARE := PickTemplates.new(
	"shelf wrench",
	Families.WRENCH,
	Archetypes.ISOLATION,
	Rarities.RARE,
	"JJ[J[J[T]PT"
)

## TJ[TJ
static var WRENCH_TRICKS_BASIC := PickTemplates.new(
	"trick wrench",
	Families.WRENCH,
	Archetypes.TRICKS,
	Rarities.BASIC,
	"TJ[TJ"
)

## TT[J[J]TT
static var WRENCH_TRICKS_GREAT := PickTemplates.new(
	"solution",
	Families.WRENCH,
	Archetypes.TRICKS,
	Rarities.GREAT,
	"TT[J[J]TT"
)

## J
static var WRENCH_TRICKS_TRASH := PickTemplates.new(
	"feather wrench",
	Families.WRENCH,
	Archetypes.TRICKS,
	Rarities.TRASH,
	"J"
)

## TTJ
static var WRENCH_TRICKS_COMMON := PickTemplates.new(
	"narrow wrench",
	Families.WRENCH,
	Archetypes.TRICKS,
	Rarities.COMMON,
	"TTJ"
)

## P[J[JJ[J]P
static var WRENCH_TRICKS_RARE := PickTemplates.new(
	"frost bolt",
	Families.WRENCH,
	Archetypes.TRICKS,
	Rarities.RARE,
	"P[J[JJ[J]P"
)

#endregion

#region special use picks

## T[TT[PTT
static var NEEDLE := PickTemplates.new(
	"needle",
	Families.NONE,
	Archetypes.BULK_TEST,
	Rarities.TEMPORARY,
	"T[TT[PTT"
)

## PPJJJ[PPJJJ
static var NAIL := PickTemplates.new(
	"nail",
	Families.NONE,
	Archetypes.END_TURN,
	Rarities.TEMPORARY,
	"PPJJJ[PPJJJ"
)

## P.RT
static var FISHHOOK := PickTemplates.new(
	"fishhook",
	Families.NONE,
	Archetypes.JUMP_TEST,
	Rarities.TEMPORARY,
	"P.RT"
)

## P[PP[PPP]JJ
static var HAIRPIN := PickTemplates.new(
	"hairpin",
	Families.NONE,
	Archetypes.THREE_PUSH,
	Rarities.TEMPORARY,
	"P[PP[PPP]JJ"
)

## PT[PT[PPT]P
static var TOOTHPICK := PickTemplates.new(
	"toothpick",
	Families.NONE,
	Archetypes.BULK_PUSH,
	Rarities.TEMPORARY,
	"PT[PT[PPT]P"
)

## PPP[JJJ]PPP
static var OLD_KEY := PickTemplates.new(
	"old key",
	Families.NONE,
	Archetypes.ISOLATION,
	Rarities.TEMPORARY,
	"PPP[JJJ]PPP"
)
#endregion

static var valid_templates: Array[PickTemplates] = [
	RAKE_BULK_PUSH_BASIC,
	RAKE_BULK_PUSH_GREAT,
	RAKE_BULK_PUSH_TRASH,
	RAKE_BULK_PUSH_COMMON,
	RAKE_BULK_PUSH_RARE,
	RAKE_BULK_TEST_BASIC,
	RAKE_BULK_TEST_GREAT,
	RAKE_BULK_TEST_TRASH,
	RAKE_BULK_TEST_COMMON,
	RAKE_BULK_TEST_RARE,
	RAKE_HYBRID_S_BASIC,
	RAKE_HYBRID_S_GREAT,
	RAKE_HYBRID_S_TRASH,
	RAKE_HYBRID_S_COMMON,
	RAKE_HYBRID_S_RARE,
	RAKE_GAPS_BASIC,
	RAKE_GAPS_GREAT,
	RAKE_GAPS_TRASH,
	RAKE_GAPS_COMMON,
	RAKE_GAPS_RARE,
	DIAMOND_DARK_BASIC,
	DIAMOND_DARK_GREAT,
	DIAMOND_DARK_TRASH,
	DIAMOND_DARK_COMMON,
	DIAMOND_DARK_RARE,
	DIAMOND_THREE_PUSH_BASIC,
	DIAMOND_THREE_PUSH_GREAT,
	DIAMOND_THREE_PUSH_TRASH,
	DIAMOND_THREE_PUSH_COMMON,
	DIAMOND_THREE_PUSH_RARE,
	DIAMOND_FINISHER_BASIC,
	DIAMOND_FINISHER_GREAT,
	DIAMOND_FINISHER_TRASH,
	DIAMOND_FINISHER_COMMON,
	DIAMOND_FINISHER_RARE,
	DIAMOND_REVEAL_BASIC,
	DIAMOND_REVEAL_GREAT,
	DIAMOND_REVEAL_TRASH,
	DIAMOND_REVEAL_COMMON,
	DIAMOND_REVEAL_RARE,
	HOOK_PRECISE_BASIC,
	HOOK_PRECISE_GREAT,
	HOOK_PRECISE_TRASH,
	HOOK_PRECISE_COMMON,
	HOOK_PRECISE_RARE,
	HOOK_PUSHY_BASIC,
	HOOK_PUSHY_GREAT,
	HOOK_PUSHY_TRASH,
	HOOK_PUSHY_COMMON,
	HOOK_PUSHY_RARE,
	HOOK_JUMP_TEST_BASIC,
	HOOK_JUMP_TEST_GREAT,
	HOOK_JUMP_TEST_TRASH,
	HOOK_JUMP_TEST_COMMON,
	HOOK_JUMP_TEST_RARE,
	HOOK_CLOSE_TEST_BASIC,
	HOOK_CLOSE_TEST_GREAT,
	HOOK_CLOSE_TEST_TRASH,
	HOOK_CLOSE_TEST_COMMON,
	HOOK_CLOSE_TEST_RARE,
	WRENCH_END_TURN_BASIC,
	WRENCH_END_TURN_GREAT,
	WRENCH_END_TURN_TRASH,
	WRENCH_END_TURN_COMMON,
	WRENCH_END_TURN_RARE,
	WRENCH_LOCK_N_BLOCK_BASIC,
	WRENCH_LOCK_N_BLOCK_GREAT,
	WRENCH_LOCK_N_BLOCK_TRASH,
	WRENCH_LOCK_N_BLOCK_COMMON,
	WRENCH_LOCK_N_BLOCK_RARE,
	WRENCH_ISOLATION_BASIC,
	WRENCH_ISOLATION_GREAT,
	WRENCH_ISOLATION_TRASH,
	WRENCH_ISOLATION_COMMON,
	WRENCH_ISOLATION_RARE,
	WRENCH_TRICKS_BASIC,
	WRENCH_TRICKS_GREAT,
	WRENCH_TRICKS_TRASH,
	WRENCH_TRICKS_COMMON,
	WRENCH_TRICKS_RARE,
]

static var temporary_picks: Array[PickTemplates] = [
	NEEDLE,
	NAIL,
	FISHHOOK,
	HAIRPIN,
	TOOTHPICK,
	OLD_KEY,
]
