extends TextureRect
## A single card effect icon
class_name EffectIcon

## Effect flavor to use for the texture of this icon
@export var effect: Effects

func redraw() -> void:
	texture = effect.texture
	var new_size: Vector2 = texture.get_size()
	custom_minimum_size = new_size

const SELF_PACKED := preload("res://objects/card/effect_icon.tscn")

## Create a new instantiated instance from data
static func build(
	effect_: Effects
) -> Node:
	var n := SELF_PACKED.instantiate()
	n.effect = effect_
	n.redraw()
	return n
