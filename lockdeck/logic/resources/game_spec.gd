extends Resource
## GameSpec tracks the status of the current game - decks, coins, etc.
class_name GameSpec

## Current coin count
@export var coins: int = 0

## Current lock. ONE INDEXED
@export var lock_number: int = 1

## Holds the full set of live cards
@export var current_deck: Array[CardSpec]

## Holds every broken card
@export var broken_picks: Array[CardSpec]

func add_coins(count: int) -> void:
	coins += count

func add_pick(pick: CardSpec) -> void:
	current_deck.append(pick)

## Marks a lock as complete, updating the difficulty
func complete_lock() -> void:
	lock_number += 1

static var LOCK_SEQUENCE := [
	1, 1, 2,
	2, 2, 3,
	3, 3, 4,
	4, 4, 5,
	5, 6, 7,
	8, 9, 10
]

static var LOOT_AMOUNTS := [50, 75, 100, 125, 150, 160, 170, 180]

## Gets the current difficulty
func get_difficulty() -> int:
	return LOCK_SEQUENCE[lock_number - 1]

func get_loot_value() -> int:
	@warning_ignore("integer_division")
	var base_value: int = LOOT_AMOUNTS[(lock_number - 1) / 3]
	return int(randf_range(base_value * 0.9, base_value * 1.1))

var _current_strat_floor := 4

func heist_complete() -> bool:
	if lock_number != _current_strat_floor:
		return false
	_current_strat_floor += 3
	return true

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

static func get_in_progress_game() -> GameSpec:
	var game := GameSpec.new()
	game.coins = 14
	game.current_deck = DeckTemplates.STANDARD.deck_gen.call()
	game.current_deck.append_array(PickGenerator.get_many_base_cards(3))
	game.broken_picks = PickGenerator.get_many_base_cards(4)
	game.lock_number = 4
	return game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_deck = []
	broken_picks = []
