extends Control

signal tutorial_start(int)
signal return_to_deck_select()

static var STAGE_DESCRIPTIONS: Dictionary[int, String] = {
	1: "Start story mode from the beginning, learning the very basics.",
	2: "Push puzzle #1",
	3: "Push puzzle #2",
	4: "Spike depths and how to avoid them.",
	5: "Spike puzzle #1",
	6: "Spike puzzle #2",
	7: "Spike puzzle #3",
	8: "Reveal picks, break depths, and interpreting warnings.",
	9: "Reveal puzzle #1",
	10: "Reveal puzzle #2",
	11: "Test picks and how to interpret tests.",
	12: "Test puzzle #1",
	13: "Test puzzle #2",
	14: "Test puzzle #3",
	15: "Test puzzle #4",
	16: "Bounce depths, caution marks, and more test.",
	17: "Test puzzle #5",
	18: "Test puzzle #6",
	19: "Test puzzle #7",
	20: "Skip and the many uses of jam.",
	21: "Jam puzzle #1",
	22: "Jam puzzle #2",
	23: "Jam puzzle #3",
	24: "A final sendoff and your first job."
}

var next_stage := 0

func set_next_stage(stage: int) -> void:
	if stage in STAGE_DESCRIPTIONS:
		%Info.text = STAGE_DESCRIPTIONS[stage]
	else:
		%Info.text = "Stage %s" % stage
	if next_stage in buttons:
		buttons[next_stage].button_pressed = false
	next_stage = stage

func on_enter() -> void:
	var stage := MetaProgression.instance().tutorial_level
	for i in buttons:
		if i == stage:
			buttons[i].button_pressed = true
			set_next_stage(i)
		elif i > stage:
			buttons[i].disabled = true
	if stage >= len(buttons):
		%Info.text = "Choose a stage to replay."

func start_tutorial() -> void:
	tutorial_start.emit(next_stage)

var buttons: Dictionary[int, Button] = {}

func _ready() -> void:
	var i := 1
	for vstack in %ButtonColumns.get_children():
		for button in vstack.get_children():
			if button is Button:
				button.text = str(i)
				button.pressed.connect(set_next_stage.bind(i))
				buttons[i] = button
			i += 1
	
	%GoButton.pressed.connect(start_tutorial)
	$ReturnButton.pressed.connect(return_to_deck_select.emit)
	
	if get_tree().current_scene == self:
		MetaProgression.instance().tutorial_level = 0
		MetaProgression.save()
		on_enter()
