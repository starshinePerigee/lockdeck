extends Control

static var BASS_1: AudioStreamMP3 = preload("res://assets/bgm/bass_4_easy_loop.mp3")
static var GUITAR_1: AudioStreamMP3 = preload("res://assets/bgm/guitar_1_minor_mel_loop.mp3")

@export var heist = 0

func next_heist() -> void:
	heist += 1
	$HeistLabel.text = "Heist: %s" % heist
	$BgmMain.lock_start(heist)

func main_menu() -> void:
	heist = 0
	$HeistLabel.text = "Heist: %s" % heist
	$BgmMain.title_screen()

func _ready() -> void:
	$Stack/MenuButton.pressed.connect(main_menu)
	$Stack/LockButton.pressed.connect(next_heist)
	$Stack/StratButton.pressed.connect($BgmMain.strat_start)
	$Stack/VictoryButton.pressed.connect($BgmMain.victory_start)
	$Stack/FailureButton.pressed.connect($BgmMain.fail_start)

	$Effects/FinalTurnButton.pressed.connect($BgmMain/AmbienceManager.play_final_turn)
	$Effects/StartBugsButton.pressed.connect($BgmMain/AmbienceManager.start_bugs)
	$Effects/ShiftBugsButton.pressed.connect($BgmMain/AmbienceManager.shift_bugs)
	$Effects/EndBugsButton.pressed.connect($BgmMain/AmbienceManager.stop_bugs)
