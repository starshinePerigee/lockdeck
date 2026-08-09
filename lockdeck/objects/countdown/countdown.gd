extends TextureButtonWithLabel
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
			texture_normal = CD_TWO
		elif count == 4:
			_label_text = "four turns remain"
			texture_normal = CD_TWO
		elif count == 3:
			_label_text = "three turns remain"
			texture_normal = CD_TWO
		elif count == 2:
			_label_text = "two turns remain"
			texture_normal = CD_TWO
		elif count == 1:
			_label_text = "one turn remains"
			texture_normal = CD_ONE
		elif count == 0:
			_label_text = "no turns remain"
			texture_normal = CD_ZERO
		else:
			_label_text = "darkness looms"
			texture_normal = CD_SKULL
		$Label.text = _label_text
		$Label.position = _label_pos

func reset_text() -> void:
	$Label.text = _label_text

func _ready() -> void:
	pressed.connect(candle_clicked.emit)
	_label_pos = $Label.position
