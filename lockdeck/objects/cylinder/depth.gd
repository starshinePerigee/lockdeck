extends Control
## The view for a single depth in a pin.
class_name Depth

const PREV_SPACING := 12

## Flavor to show for this depth.
@export var flavor: Depths = Depths.DEBUG:
	set(v):
		flavor = v
		_redraw()

@export var result: Results = Results.DEBUG:
	set(v):
		result = v
		$Result.visible = result != Results.EMPTY
		$Result.texture = result.texture

@export var show_jam_result: bool = false:
	set(v):
		show_jam_result = v
		$JamResult.visible = show_jam_result

@export var exhausted: bool = false:
	set(v):
		exhausted = v
		_update_exhaust()

func _update_exhaust() -> void:
	# TODO: this should be a shader to replace the normal background texture
	# as modulation breaks the color limitations
	if exhausted:
		$DepthTexture.modulate = Color("B4B4B4")
	else:
		$DepthTexture.modulate = Color("ffffff")

func set_hints(letters: String, color: Color = Color()):
	if letters:
		$HintTracker.visible = true
	if len(letters) > 8:
		$HintTracker.text = "*" + letters.substr(len(letters) - 7, 7)
	else:
		$HintTracker.text = letters
	$HintTracker.add_theme_color_override("font_color", color)

func _redraw() -> void:
	if not is_node_ready():
		await ready
		
	$DepthTexture.texture = flavor.texture
	$DepthTexture.size = $DepthTexture.texture.get_size()
	size = $DepthTexture.size

const TOOLTIP := preload("res://objects/displays/depth_display.tscn")

func request_tooltip() -> void:
	var tooltip: Control = TOOLTIP.instantiate()
	tooltip.depth = flavor
	TooltipManager.request_widget_tooltip($DepthTexture.get_global_rect(), tooltip)

func _ready() -> void:
	mouse_entered.connect(request_tooltip)
