extends Resource
## This stores a single game state for saving/loading mid-game
class_name StateSpec

@export var all_cards: AllCardsSpec
@export var lock: LockSpec
@export var countdown: int
@export var break_bag: Array[bool]
@export var turn_count: int

func reify() -> void:
	if all_cards:
		all_cards.reify()
	if lock:
		lock.reify()

func _init(
	all_cards_: AllCardsSpec = null,
	lock_: LockSpec = null,
	countdown_: = 99,
	break_bag_: = [],
	_deprecated: int = 0,
	turn_count_: int = 0,
):
	all_cards = all_cards_
	lock = lock_
	countdown = countdown_
	if len(break_bag_) == 0:
		break_bag = [false, false, false]
	else:
		break_bag = break_bag_
	turn_count = turn_count_