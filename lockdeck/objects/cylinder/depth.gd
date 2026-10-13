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
		if exhausted and flavor not in [Depths.BASE]:
			$DepthTexture.material = material_exhaust
		else:
			$DepthTexture.material = material_normal

enum ManualMarkState {
	UNMARKED,
	GOOD,
	BAD
}

const MARK_BAD := preload("res://assets/pin/manualmark_bad.png")
const MARK_GOOD := preload("res://assets/pin/manualmark_good.png")

@export var manual_mark: ManualMarkState = ManualMarkState.UNMARKED:
	set(v):
		if flavor not in Depths.MARKS:
			manual_mark = ManualMarkState.UNMARKED
		else:
			manual_mark = v
		
		match manual_mark:
			ManualMarkState.UNMARKED:
				$ManualMark.visible = false
			ManualMarkState.GOOD:
				$ManualMark.texture = MARK_GOOD
				$ManualMark.visible = true
			ManualMarkState.BAD:
				$ManualMark.texture = MARK_BAD
				$ManualMark.visible = true

const TESTRESULT_CLEAR := preload("res://assets/pin/testresult_safe.png")
const TESTRESULT_INTERESTING := preload("res://assets/pin/testresult_caution.png")
const TESTRESULT_DANGEROUS := preload("res://assets/pin/testresult_danger.png")
const TESTRESULT_NONE := preload("res://assets/pin/testresult_nothing.png")

@export var test_result: PinSpec.RevealLevel = PinSpec.RevealLevel.UNKNOWN:
	set(v):
		test_result = v
		match test_result:
			PinSpec.RevealLevel.CLEAR:
				$TestResult.texture = TESTRESULT_CLEAR
			PinSpec.RevealLevel.INTERESTING:
				$TestResult.texture = TESTRESULT_INTERESTING
			PinSpec.RevealLevel.DANGEROUS:
				$TestResult.texture = TESTRESULT_DANGEROUS
			PinSpec.RevealLevel.UNKNOWN:
				$TestResult.texture = TESTRESULT_NONE
			PinSpec.RevealLevel.REVEALED:
				$TestResult.texture = TESTRESULT_NONE
		$TestResult.visible = test_result != PinSpec.RevealLevel.REVEALED

func _redraw() -> void:
	if not is_node_ready():
		await ready
		
	$DepthTexture.texture = flavor.texture
	$DepthTexture.size = $DepthTexture.texture.get_size()
	manual_mark = manual_mark
	size = $DepthTexture.size

var manual_lock := false

func _gui_input(event: InputEvent) -> void:
	if (
		not manual_lock
		and event is InputEventMouseButton
		and event.pressed
		and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT)
		and get_global_rect().has_point(event.global_position)
		and flavor in Depths.MARKS
	):
		if event.button_index == MOUSE_BUTTON_LEFT:
			if manual_mark == ManualMarkState.GOOD:
				manual_mark = ManualMarkState.UNMARKED
			else:
				manual_mark = ManualMarkState.GOOD
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if manual_mark == ManualMarkState.BAD:
				manual_mark = ManualMarkState.UNMARKED
			else:
				manual_mark = ManualMarkState.BAD

const TOOLTIP := preload("res://objects/displays/depth_tooltip.tscn")

func request_tooltip() -> void:
	var tooltip: Control = TOOLTIP.instantiate()
	tooltip.depth = flavor
	TooltipManager.request_widget_tooltip($DepthTexture.get_global_rect, tooltip)

func exhaust() -> void:
	print("zz")
	exhausted = not exhausted

static var material_normal: ShaderMaterial = null
static var material_exhaust: ShaderMaterial = null

func _ready() -> void:
	mouse_entered.connect(request_tooltip)
	
	if not material_normal:
		material_normal = $DepthTexture.material
		material_exhaust = $DepthTexture.material.duplicate()
		material_exhaust.set_shader_parameter("exhaust", true)
	
#	mouse_entered.connect(exhaust)
