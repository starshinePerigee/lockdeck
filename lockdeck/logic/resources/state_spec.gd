extends Resource
## This stores a single game state for saving/loading mid-game
class_name StateSpec

@export var all_cards: AllCardsSpec
@export var lock: LockSpec
@export var countdown: int

func reify() -> void:
	all_cards.reify()
	lock.reify()

func _init(
	all_cards_: AllCardsSpec = null,
	lock_: LockSpec = null,
	countdown_: = 0
):
	all_cards = all_cards_
	lock = lock_
	countdown = countdown_