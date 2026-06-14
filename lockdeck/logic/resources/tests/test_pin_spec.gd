extends Node2D

@export var p: PinSpec

func w():
	$Pin.load_spec(p)
	$OOBLabel.visible = false

func adv():
	var a := int($AdvanceEdit.text)
	var oob := p.advance_pin(a)
	w()
	$OOBLabel.visible = oob

func jam():
	var j := int($JamEdit.text)
	p.jam_count += j
	w()

func rst():
	p.reset_pin()
	w()

func _ready():
	$AdvanceButton.pressed.connect(adv)
	$JamButton.pressed.connect(jam)
	$ResetButton.pressed.connect(rst)
	w()

func _init():
	p = PinSpec.new()
