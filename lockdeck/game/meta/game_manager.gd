extends Control
## This scene represents a single game and manages the transition between scenes

signal heist_start
signal lock_start
signal shop_start
signal failure_start
signal victory_start

signal end_game

var game: GameSpec

func auto_complete_level() -> void:
	$GameCore.solve_lock()
	$GameCore.continue_to_next.emit()

func reveal_level() -> void:
	$GameCore.reveal_lock()

func break_three() -> void:
	for __ in 3:
		$GameCore.break_from_hand()

# Note: "first lock" and any of the "x to between" animations on GameManager's AnimationPlayer
# call between.animate on completion, but animation is skipped if between is in tutorial mode.

func begin_tutorial() -> void:
	$AnimationPlayer.play("RESET")
	game = GameSpec.new()
	game.tutorial_mode = true
	game.stage = 1  # needed to show the display correctly
	game.stage = 11  # TODO
	game.current_deck = []
	game.save()
	$BetweenLocks.set_text("first")
	$BetweenLocks/AnimationPlayer.play("go_tutorial")
	$AnimationPlayer.play("first lock")

func begin_new_game(starter_deck: Array[CardSpec]) -> void:
	$AnimationPlayer.play("RESET")
	game = GameSpec.new()
	game.current_deck = starter_deck
	game.build_new_lockset_deck(LockDeck.GameArcs.EARLY)
	game.save()
	$StrategyHub.set_game(game)
	$LootMain.game = game
	$BetweenLocks.reset(0)
	$AnimationPlayer.play("first lock")
	heist_start.emit(1)

func load_saved_game(saved_game: GameSpec):
	$AnimationPlayer.play("RESET")
	game = saved_game
	$StrategyHub.set_game(game)
	$LootMain.game = game
	$BetweenLocks/SpeedBonusLabel.visible = false
	print("Loading lock in heist: %s" % game.lock_in_heist())
	$BetweenLocks.reset(game.lock_in_heist() - 1)
	if game.tutorial_mode:
		if game.get_next_level().stage == LevelSpec.Stages.SPECIFIC:
			$BetweenLocks.set_text("challenge")
		else:
			$BetweenLocks.set_text("first")
		$BetweenLocks/AnimationPlayer.play("go_tutorial")
	$AnimationPlayer.play("first lock")
	heist_start.emit(game.heist_number())

const FX_LOCK_ROLL_IN := preload("res://assets/fx/lock_roll_in.ogg")
const FX_LOCK_ROLL_OUT := preload("res://assets/fx/lock_roll_out.ogg")
const FX_LOOT_ROLL_IN := preload("res://assets/fx/loot_roll_in.ogg")
const FX_LOOT_ROLL_OUT := preload("res://assets/fx/drawers_roll.ogg")

# note that lock_complete echos into advance_from_between via
# GameManager/AnimationPlayer's lock_to_between, which calls 
# BetweenLocks.animate(), which emits continue_to_next, which calls
# continue_to_next
func lock_complete() -> void:
	game.break_picks($GameCore/TrashMain.cards)
	if not game.tutorial_mode and $GameCore/LockBody/CountdownMain.count >= 2:
		game.add_coins(10)
		$BetweenLocks/SpeedBonusLabel.visible = true
	else:
		$BetweenLocks/SpeedBonusLabel.visible = false
	
	if game.tutorial_mode:
		# Tutorial mode continuation logic
		# determine if we're continuing:
		var retry := false
		match game.get_next_level().stage:
			LevelSpec.Stages.TUTORIAL:
				game.stage += 1
			LevelSpec.Stages.SPECIFIC:
				# check for broken picks
				if len($GameCore/TrashMain.cards) > 0:
					retry = true
				else:
					game.stage += 1
			_:
				push_error("Tutorial current state weird? %s" % game.get_next_level().stage)
				game.stage += 1
		
		# Determine what to show between:
		match game.get_next_level().stage:
			LevelSpec.Stages.TUTORIAL:
				$BetweenLocks.set_text("complete")
			LevelSpec.Stages.SPECIFIC:
				if retry:
					$BetweenLocks.set_text("retry")
				else:
					$BetweenLocks.set_text("challenge")
			_:
				print("Completed tutorial!")
	else:
		game.stage += 1
	
	game.next_lock_deck = null
	game.in_progress = null
	game.save()
	$AnimationPlayer.play("lock to between", -12)
	GlobalEffects.request(FX_LOCK_ROLL_OUT)

func advance_from_between() -> void:
	var next_level: LevelSpec = game.get_next_level()
	print(
		"Next level: %s %s %s" % [
			LevelSpec.Stages.find_key(next_level.stage),
			next_level.difficulty,
			next_level.tutorial_level
		]
	)
	match next_level.stage:
		LevelSpec.Stages.VICTORY:
			do_victory()
		LevelSpec.Stages.LOOT_STRAT:
			game.build_new_lockset_deck(next_level.arc)
			next_loot(next_level.loot)
		LevelSpec.Stages.LOCK:
			lock_start.emit()
			$GameCore.setup_interface()
			next_lock(next_level)
		LevelSpec.Stages.SPECIFIC:
			lock_start.emit()
			$GameCore.setup_interface(next_level.interface)
			load_state(next_level.state)
		LevelSpec.Stages.TUTORIAL:
			lock_start.emit()
			$GameCore.setup_interface(next_level.interface)
			await load_state(next_level.state)
			$Tutorializer.tutorialize(next_level.tutorial_level)
			$Tutorializer.do_step()

func next_loot(loot_value: int) -> void:
	$LootMain.do_loot(loot_value)
	$AnimationPlayer.play("between to loot", -12)
	GlobalEffects.request(FX_LOOT_ROLL_IN)
	shop_start.emit()

func end_loot() -> void:
	if game.game_complete():
		end_game.emit()
	else:
		$StrategyHub.reset()
		$AnimationPlayer.play("loot to strategy")
		GlobalEffects.request(FX_LOOT_ROLL_OUT, -6)

func end_strategy() -> void:
	game.stage += 1
	game.save()
	$BetweenLocks/SpeedBonusLabel.visible = false
	$BetweenLocks.reset(0)
	$AnimationPlayer.play("strategy to between")
	heist_start.emit(game.heist_number())

func do_victory() -> void:
	GameSpec.clear_save()
	$LootMain.do_victory(game.coins)
	$AnimationPlayer.play("between to loot")
	victory_start.emit()

## Show the failure screen - called from gamecore
func do_failure() -> void:
	GameSpec.clear_save()
	$AnimationPlayer.play("lock to failure")
	failure_start.emit()

func update_state(state_spec: StateSpec) -> void:
	game.in_progress = state_spec
	game.save()

func next_lock(level: LevelSpec) -> void:
	if not game.next_lock_deck:
		game.build_new_lock_deck(level.difficulty)
	
	$GameCore.load_lock(
		LockGenerator.build_lock(
			game.next_lock_deck,
			level.pin_count
		)
	)
	$GameCore.load_game(game)
	
	$AnimationPlayer.play("between to lock")
	GlobalEffects.request(FX_LOCK_ROLL_IN)
	await $AnimationPlayer.animation_finished
	$GameCore.draw_to_five()
	update_state($GameCore.get_game_state())

## load_state is used to both load a game saved mid-stage as well as all
## load all the tutorial functions
func load_state(state: StateSpec) -> void:
	$GameCore.load_in_progress(game, state)
	$AnimationPlayer.play("between to lock")
	GlobalEffects.request(FX_LOCK_ROLL_IN)
	await $AnimationPlayer.animation_finished
	$GameCore.draw_to_five()

## Abandon the current game. Call begin_new_game after
func abort_and_reset() -> void:
	$AnimationPlayer.play("RESET")

func _ready() -> void:
	global_position = Vector2(0, 0)
	$BetweenLocks.continue_to_next.connect(advance_from_between)
	$LootMain.continue_to_next.connect(end_loot)
	$GameCore.continue_to_next.connect(lock_complete)
	$GameCore.continue_to_failure.connect(do_failure)
	$GameCore.new_state.connect(update_state)
	$StrategyHub.continue_to_next.connect(end_strategy)
	$FailureScreen.continue_to_title.connect(end_game.emit)
	
	$MenuButton.pressed.connect($MenuMain.show_menu)
	$MenuButton.pressed.connect($GameCore.set_menu_status.bind(true))
	$MenuMain/MenuWidget.closed.connect($GameCore.set_menu_status.bind(false))
	$MenuMain.return_to_title.connect($Tutorializer.hide_all)
	$MenuMain.auto_complete_level.connect(auto_complete_level)
	$MenuMain.reveal_level.connect(reveal_level)
	$MenuMain.break_three.connect(break_three)
	$Tutorializer.core = $GameCore

	# if name == "__main__:
	if get_tree().current_scene == self:
		begin_new_game(DeckTemplates.STANDARD.deck_gen.call())
