@tool
extends Control
class_name EffectIcon

@export var effect: EffectData.EffectFlavors = EffectData.EffectFlavors.DEBUG:
	set(v):
		effect = v
		_redraw()
	
@export var small: bool = true:
	set(v):
		small = v
		_redraw()
		
@export var value: int = 0:
	set(v):
		value = v
		_redraw()

@export var refrect_visible: bool = true:
	set(v):
		refrect_visible = v
		$ReferenceRect.visible = v

func _redraw():
	if not is_node_ready():
		await ready
	var texture = (
		EffectData.get_def(effect).texture_small 
		if small
		else EffectData.get_def(effect).texture
	)
	$Icon.texture = texture
	var new_size = $Icon.texture.get_size()
	custom_minimum_size = new_size
	$ValueLabel.text = str(value)

func _ready() -> void:
	_redraw()
