extends Resource
## LockSpec is a dataclass that entirely defines a lock.
class_name LockSpec

## Holds all the templates that went into creating this lock
@export var lock_deck: LockDeck

## Holds the actual PinSpecs
@export var pins: Array[PinSpec]

func reify() -> void:
	lock_deck.reify()
	for pin in pins:
		pin.reify()

func _init(
	pins_: Array[PinSpec] = [],
	lock_deck_: LockDeck = null,
):
	# pins should only ever be [] on first game load
	pins = pins_ 
	lock_deck = lock_deck_
