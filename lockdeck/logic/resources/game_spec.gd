extends Resource
## GameSpec tracks the status of the current game - decks, coins, etc.
class_name GameSpec

## Current coin count
@export var coins: int = 0

## Current lock. ONE INDEXED
@export var lock_number: int = 0

## Current heist, ONE INDEXED
@export var heist_number: int = 1

@export var current_stage: int = -1

## Holds the full set of live cards
@export var current_deck: Array[CardSpec]

## Holds every broken card
@export var broken_picks: Array[CardSpec]

## Holds picks removed forever
@export var removed_forever_picks: Array[CardSpec]

func add_coins(count: int) -> void:
	coins += count

func spend_coins(count: int) -> void:
	coins -= count

func add_pick(pick: CardSpec) -> void:
	current_deck.append(pick)

const LOCK := LevelSpec.Stages.LOCK
const LOOT_STRAT := LevelSpec.Stages.LOOT_STRAT
const VICTORY := LevelSpec.Stages.VICTORY

const EARLY := LockDeck.GameArcs.EARLY
const MID := LockDeck.GameArcs.MID
const LATE := LockDeck.GameArcs.LATE

static var LOOT_SEQUENCE: Array[int] = [50, 75, 100, 125, 150, 160, 170, 180]

static var GAME_SEQUENCE: Array[LevelSpec] = [
	LevelSpec.new(EARLY, LOCK, 1, 1),
	LevelSpec.new(EARLY, LOCK, 1, 2),
	LevelSpec.new(EARLY, LOCK, 2, 1),
	LevelSpec.new(EARLY, LOOT_STRAT, LOOT_SEQUENCE[0]),
	
	LevelSpec.new(MID, LOCK, 2, 2),
	LevelSpec.new(MID, LOCK, 2, 3),
	LevelSpec.new(MID, LOCK, 3, 2),
	LevelSpec.new(MID, LOOT_STRAT, LOOT_SEQUENCE[1]),
	
	LevelSpec.new(MID, LOCK, 3, 3),
	LevelSpec.new(MID, LOCK, 3, 4),
	LevelSpec.new(MID, LOCK, 4, 3),
	LevelSpec.new(MID, LOOT_STRAT, LOOT_SEQUENCE[2]),
	
	LevelSpec.new(LATE, LOCK, 4, 3),
	LevelSpec.new(LATE, LOCK, 4, 4),
	LevelSpec.new(LATE, LOCK, 5, 3),
	LevelSpec.new(LATE, LOOT_STRAT, LOOT_SEQUENCE[3]),
	
	LevelSpec.new(LATE, LOCK, 4, 5),
	LevelSpec.new(LATE, LOCK, 5, 4),
	LevelSpec.new(LATE, LOCK, 5, 5),
	LevelSpec.new(LATE, LOOT_STRAT, LOOT_SEQUENCE[4]),
	
	LevelSpec.new(LATE, LOCK, 5, 6),
	LevelSpec.new(LATE, LOCK, 5, 7),
	LevelSpec.new(LATE, LOCK, 5, 8),
	LevelSpec.new(LATE, VICTORY),
]

func get_next_level() -> LevelSpec:
	if not game_complete():
		current_stage += 1
	
	var next_stage: LevelSpec = GAME_SEQUENCE[current_stage]
	
	match next_stage.stage:
		LOCK:
			lock_number += 1
		LOOT_STRAT:
			heist_number += 1
		_:
			pass
	
	return next_stage

func game_complete() -> bool:
	return current_stage >= len(GAME_SEQUENCE) - 1

func get_max_pin_count() -> int:
	var pin_count := 0
	var stage := current_stage + 1
	
	for level in GAME_SEQUENCE.slice(stage, -1):
		if level.stage != LOCK:
			break
		pin_count = max(pin_count, level.pin_count)
	return pin_count

## Updates the broken_picks deck, removing the picks from the deck.
func break_picks(picks: Array[CardSpec]) -> void:
	for broke in picks:
		if broke in current_deck:
			current_deck.erase(broke)
		else:
			push_warning(
				"Could not find broken pick %s (%s) in deck record!" 
				% [broke.pick_name, broke.unique_id]
			)
	broken_picks.append_array(picks)

## Moves a pick from broken to active. Does not check for validity (deck size or money)
func repair_pick(pick: CardSpec) -> void:
	if pick not in broken_picks:
		push_error(
			"Tried to repair pick %s [%s] but not in broken picks!"
			% [pick.pick_name, pick.unique_id]
		)
		return
	current_deck.append(pick)
	broken_picks.erase(pick)
	pick.repair_count += 1

## Removes a pick from the broken picks collection, but keeps it
func remove_broken_pick_forever(pick: CardSpec) -> void:
	if pick not in broken_picks:
		push_error(
			"Tried to remove pick %s [%s] but not in broken picks!"
			% [pick.pick_name, pick.unique_id]
		)
		return
	removed_forever_picks.append(pick)
	broken_picks.erase(pick)

func remove_real_pick_forever(pick: CardSpec) -> void:
	if pick not in current_deck:
		push_error(
			"Tried to sell pick %s [%s] but not in current deck!"
			% [pick.pick_name, pick.unique_id]
		)
		return
	current_deck.erase(pick)

static func get_in_progress_game() -> GameSpec:
	var game := GameSpec.new()
	game.heist_number = 2
	game.lock_number = 4
	game.current_stage = 5
	game.coins = 28
	game.current_deck = DeckTemplates.STANDARD.deck_gen.call()
	game.current_deck.append_array(PickGenerator.get_many_base_cards(3))
#	game.broken_picks = PickGenerator.get_many_base_cards(7)
#	game.removed_forever_picks = PickGenerator.get_many_base_cards(2)
	for i in len(game.broken_picks):
		game.broken_picks[i].repair_count = i
	game.lock_number = 4
	return game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_deck = []
	broken_picks = []
	removed_forever_picks = []
