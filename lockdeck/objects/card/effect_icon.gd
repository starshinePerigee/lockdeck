extends Control
## A single card effect icon
class_name EffectIcon

## Effect flavor to use for the texture of this icon
@export var effect: Effects

## The number to display for the value
@export var value: int

## If the value number should be shown.
@export var show_text: bool

func redraw() -> void:
	var texture := effect.texture
	$Icon.texture = texture
	var new_size: Vector2 = $Icon.texture.get_size()
	custom_minimum_size = new_size
	
	if show_text:
		$ValueLabel.text = str(value)
		$ValueLabel.visible = true
	else:
		$ValueLabel.visible = false

const SELF_PACKED := preload("res://objects/card/effect_icon.tscn")

## Create a new instantiated instance from data
static func build(
	effect_: Effects,
	value_: int = 0,
	show_text_: bool = false 
) -> Node:
	var n := SELF_PACKED.instantiate()
	n.effect = effect_
	if show_text_:
		n.show_text = true
		n.value = value_
	else:
		n.show_text = false
		n.value = 0
	n.redraw()
	return n
