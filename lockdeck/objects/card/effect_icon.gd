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

@export var show_text: bool = false:
	set(v):
		show_text = v
		if not is_node_ready():
			await ready
		$ValueLabel.visible = v and not hide_all

@export var hide_all: bool = false:
	set(v):
		hide_all = v
		if not is_node_ready():
			await ready
		$ValueLabel.visible = v and not hide_all
		$Icon.visible = not hide_all
		if v:
			$ReferenceRect.border_color = Color(0, 255, 0)
		else:
			$ReferenceRect.border_color = Color(255, 0, 0)

@export var refrect_visible: bool = true:
	set(v):
		refrect_visible = v
		if not is_node_ready():
			await ready
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
