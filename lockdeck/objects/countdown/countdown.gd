extends Control
## The countdown clock/candle

const CD_TWO := preload("res://assets/countdown/countdown_2.png")
const CD_ONE := preload("res://assets/countdown/countdown_1.png")
const CD_ZERO := preload("res://assets/countdown/countdown_0.png")
const CD_SKULL := preload("res://assets/countdown/countdown_x.png")

func set_count(count: int) -> void:
	if count > 4:
		$Label.text = "%s turns remain"
		$TextureRect.texture = CD_TWO
	elif count == 4:
		$Label.text = "four turns remain"
		$TextureRect.texture = CD_TWO
	elif count == 3:
		$Label.text = "three turns remain"
		$TextureRect.texture = CD_TWO
	elif count == 2:
		$Label.text = "two turns remain"
		$TextureRect.texture = CD_TWO
	elif count == 1:
		$Label.text = "one turn remains"
		$TextureRect.texture = CD_ONE
	elif count == 0:
		$Label.text = "no turns remain"
		$TextureRect.texture = CD_ZERO
	else:
		$Label.text = "darkness looms"
		$TextureRect.texture = CD_SKULL
	