extends Resource
## GameSpec tracks the status of the current game - decks, coins, etc.
class_name GameSpec

## Current coin count
@export var coins: int = 0

## Current lock difficulty
@export var difficulty: int = 0

## Holds the full set of live cards
@export var current_deck: Array[CardSpec]

## Holds every broken card
@export var broken_picks: Array[CardSpec]

## Marks a lock as complete, updating the difficulty
func complete_lock() -> void:
	difficulty += 1

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_deck = []
	broken_picks = []
