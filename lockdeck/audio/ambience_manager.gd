extends Node
## Handles queing and playing ambience as requested by bgm main

func set_play(
	player: AudioStreamPlayer,
	tween: Tween,
	make_playing: bool,
	volume: float,
	ramp_in := 5.0,
	ramp_out := 5.0
) -> Tween:
	if tween:
		tween.kill()
	var new_tween := get_tree().create_tween()
	if make_playing:
		if not player.playing:
			player.play()
		new_tween.tween_property(player, "volume_db", volume, ramp_in)
	else:
		new_tween.tween_property(player, "volume_db", -80, ramp_out)
		new_tween.tween_callback(player.stop)
	return new_tween

@onready var fire_db: float = $CracklePlayer.volume_db
var _fire_tween: Tween

func set_fire(fire_on := true) -> void:
	_fire_tween = set_play(
		$CracklePlayer, 
		_fire_tween, 
		fire_on,
		fire_db
	)

@onready var wind_db: float = $WindPlayer.volume_db
var _wind_tween: Tween

func set_wind(wind_on := true) -> void:
	_wind_tween = set_play(
		$WindPlayer,
		_wind_tween,
		wind_on,
		wind_db,
		10.0,
		8.0
	)

@onready var night_db: float = $WindPlayer.volume_db
var _night_tween: Tween

func set_night(night_on := true, volume_mod := 0.0) -> void:
	_night_tween = set_play(
		$NightPlayer, 
		_night_tween,
		night_on,
		night_db + volume_mod,
		3.0,
		8.0
	)


func title_screen() -> void:
	set_wind(true)
	
	$NightPlayer.volume_db = -30
	set_night(true)
	
	$CracklePlayer.volume_db = -60
	_fire_tween = get_tree().create_tween()
	_fire_tween.tween_interval(4)
	_fire_tween.tween_callback(set_fire.bind(true))


# Bugs!
# How do bugs work?
# On the start of a lock, we pick two bugs. During the lock, we check in at random intervals
# and randomly decide:
# if I'm playing, do I stop?
# if I'm not playing, do I start? and if so, do I start a different bug?
# if no bugs are playing, the answer to the first question is always yes.

const BUG_INTERVAL_LOW := 5.0
const BUG_INTERVAL_HIGH := 20.0
const BUG_PLAY_CHANCE := 0.3
const BUG_STOP_CHANCE := 0.05
const BUG_SWITCH_CHANCE := 0.2

static var ALL_BUGS: Array[AudioStreamMP3] = [
	preload("res://assets/ambience/cicada_1.mp3"),
	preload("res://assets/ambience/cicada_2.mp3"),
	preload("res://assets/ambience/cricket_1.mp3"),
	preload("res://assets/ambience/cricket_2.mp3"),
	preload("res://assets/ambience/cricket_3.mp3"),
]

@onready var bug_db: float = $BugPlayer1.volume_db

var bug_1: AudioStreamMP3
var _bug_1_tween: Tween
var bug_2: AudioStreamMP3
var _bug_2_tween: Tween

func get_new_bug() -> AudioStreamMP3:
	var bug: AudioStreamMP3
	while true:
		bug = ALL_BUGS.pick_random()
		if bug != bug_1 and bug != bug_2:
			break
	return bug

func check_bug(bug_number: int = 0) -> void:
	var bug: AudioStreamMP3
	var player: AudioStreamPlayer
	var tween: Tween
	
	match bug_number:
		1:
			bug = bug_1
			player = $BugPlayer1
			tween = _bug_1_tween
		2:
			bug = bug_2
			player = $BugPlayer2
			tween = _bug_2_tween
		_:
			return
	
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	
#	print("checking bug %s" % bug_number)
	if player.playing:
		if randf() < BUG_STOP_CHANCE:
#			print("stopping bug %s" % bug_number)
			tween.tween_property(player, "volume_db", -60.0, 8.0)
			tween.tween_callback(player.stop)
	else:
		if (
			(not $BugPlayer1.playing and not $BugPlayer2.playing)
			or randf() < BUG_PLAY_CHANCE
		):
			if not bug or randf() < BUG_SWITCH_CHANCE:
				bug = get_new_bug()
#				print("switching bug %s" % bug_number)
			else:
				pass
#				print("playing bug %s" % bug_number)
			player.stream = bug
			player.volume_db = -60.0
			player.play()
			tween.tween_property(player, "volume_db", bug_db, 4.0)
	
	tween.tween_interval(randf_range(BUG_INTERVAL_LOW, BUG_INTERVAL_HIGH))
	tween.tween_callback(check_bug.bind(bug_number))
	
	match bug_number:
		1:
			bug_1 = bug
			_bug_1_tween = tween
		2:
			bug_2 = bug
			_bug_2_tween = tween
		_:
			pass

func start_bugs() -> void:
	set_night(true, -6.0)
	check_bug(1)
	check_bug(2)

func shift_bugs() -> void:
	bug_1 = get_new_bug()
	bug_2 = get_new_bug()

func stop_bugs() -> void:
	set_night(false, 0.0)
	
	if _bug_1_tween:
		_bug_1_tween.kill()
	_bug_1_tween = get_tree().create_tween()
	_bug_1_tween.tween_property($BugPlayer1, "volume_db", -60, 4.0)
	_bug_1_tween.tween_callback($BugPlayer1.stop)
	bug_1 = null
	
	if _bug_2_tween:
		_bug_2_tween.kill()
	_bug_2_tween = get_tree().create_tween()
	_bug_2_tween.tween_property($BugPlayer2, "volume_db", -60, 4.0)
	_bug_2_tween.tween_callback($BugPlayer2.stop)
	bug_2 = null

func play_final_turn() -> void:
	$BugSoloPlayer.play()

func _ready() -> void:
	title_screen()
	
	if get_tree().current_scene == self:
		var timer := get_tree().create_timer(10.0)
		timer.timeout.connect(start_bugs)
