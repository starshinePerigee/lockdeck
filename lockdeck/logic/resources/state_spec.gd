extends Resource
## This stores a single game state for saving/loading mid-game
class_name StateSpec

@export var all_cards: AllCardsSpec
@export var lock: LockSpec
@export var countdown: int
@export var break_bag: Array[bool]
@export var hint_id: int
@export var turn_count: int

func reify() -> void:
	all_cards.reify()
	lock.reify()

func _init(
	all_cards_: AllCardsSpec = null,
	lock_: LockSpec = null,
	countdown_: = 0,
	break_bag_: = [],
	hint_id_: int = -1,
	turn_count_: int = 0,
):
	all_cards = all_cards_
	lock = lock_
	countdown = countdown_
	if len(break_bag) == 0:
		break_bag = []
	else:
		break_bag = break_bag_
	hint_id = hint_id_
	turn_count = turn_count_