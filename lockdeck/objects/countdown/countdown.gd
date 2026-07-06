extends Control
## The countdown clock/candle

signal candle_clicked()

const CD_TWO := preload("res://assets/countdown/countdown_2.png")
const CD_ONE := preload("res://assets/countdown/countdown_1.png")
const CD_ZERO := preload("res://assets/countdown/countdown_0.png")
const CD_SKULL := preload("res://assets/countdown/countdown_x.png")

var _label_text := "CANDLE_TEXT"
var _label_pos: Vector2
const _END_TEXT_OFFSET := 32

var show_end := false:
	set(v):
		show_end = v
		if show_end:
			$Label.text = "end turn and\nreset pins?"
			$Label.position = _label_pos + Vector2(0, _END_TEXT_OFFSET)
		else:
			$Label.text = _label_text
			$Label.position = _label_pos

@export var count: int = 2:
	set(v):
		count = v
		
		if not is_node_ready():
			await ready
		
		if count > 4:
			_label_text = "%s turns remain"
			$TextureRect.texture = CD_TWO
		elif count == 4:
			_label_text = "four turns remain"
			$TextureRect.texture = CD_TWO
		elif count == 3:
			_label_text = "three turns remain"
			$TextureRect.texture = CD_TWO
		elif count == 2:
			_label_text = "two turns remain"
			$TextureRect.texture = CD_TWO
		elif count == 1:
			_label_text = "one turn remains"
			$TextureRect.texture = CD_ONE
		elif count == 0:
			_label_text = "no turns remain"
			$TextureRect.texture = CD_ZERO
		else:
			_label_text = "darkness looms"
			$TextureRect.texture = CD_SKULL
		$Label.text = _label_text
		$Label.position = _label_pos

func reset_text() -> void:
	$Label.text = _label_text

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			candle_clicked.emit()

func _ready() -> void:
	gui_input.connect(_handle_input)
	_label_pos = $Label.position