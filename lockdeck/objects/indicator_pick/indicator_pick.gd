extends Control
## Manages the position of the indicator pick

var INTER_PIN_SPACING := 128
var STOW_POSITION := Vector2(-128 + -64, 32)

## Sets the pin to away and stowed
func go_stow() -> void:
	$Position.visible = true
	$Position.position = STOW_POSITION

## Sets the pick to a given pin index
func go_index(index: int) -> void:
	$Position.visible = true
	$Position.position = Vector2(INTER_PIN_SPACING * index, 0)

## Hides the pick
func go_hide() -> void:
	$Position.position = STOW_POSITION
	$Position.visible = false

func _ready() -> void:
	go_hide()