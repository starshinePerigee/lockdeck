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

func begin_new_game(starter_deck: Array[CardSpec]) -> void:
	$AnimationPlayer.play("RESET")
	game = GameSpec.new()
	game.current_deck = starter_deck
	game.build_new_lockset_deck(LockDeck.GameArcs.EARLY)
	$StrategyHub.set_game(game)
	$LootMain.game = game
	$BetweenLocks/SpeedBonusLabel.visible = false
	$AnimationPlayer.play("first lock")
	heist_start.emit(1)

func lock_complete():
	game.break_picks($GameCore/TrashMain.cards)
	if $GameCore/LockBody/CountdownMain.count >= 2:
		game.add_coins(10)
		$BetweenLocks/SpeedBonusLabel.visible = true
	else:
		$BetweenLocks/SpeedBonusLabel.visible = false
	game.next_lock_deck = null
	$AnimationPlayer.play("lock to between")

func advance_from_between() -> void:
	var next_level: LevelSpec = game.get_next_level()
	match next_level.stage:
		LevelSpec.Stages.VICTORY:
			do_victory()
		LevelSpec.Stages.LOOT_STRAT:
			game.build_new_lockset_deck(next_level.arc)
			next_loot(next_level.loot)
		LevelSpec.Stages.LOCK:
			lock_start.emit()
			next_lock(next_level)

func next_loot(loot_value: int) -> void:
	$LootMain.do_loot(loot_value)
	$AnimationPlayer.play("between to loot")
	shop_start.emit()

func end_loot() -> void:
	if game.game_complete():
		end_game.emit()
	else:
		$StrategyHub.reset()
		$AnimationPlayer.play("loot to strategy")

func end_strategy() -> void:
	$BetweenLocks/SpeedBonusLabel.visible = false
	$AnimationPlayer.play("strategy to between")
	heist_start.emit(game.heist_number)

func do_victory() -> void:
	$LootMain.do_victory(game.coins)
	$AnimationPlayer.play("between to loot")
	victory_start.emit()

## Show the failure screen - called from gamecore
func do_failure() -> void:
	$AnimationPlayer.play("lock to failure")
	failure_start.emit()

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

## Abandon the current game. Call begin_new_game after
func abort_and_reset() -> void:
	$AnimationPlayer.play("RESET")

func _ready() -> void:
	global_position = Vector2(0, 0)
	$BetweenLocks.continue_to_next.connect(advance_from_between)
	$LootMain.continue_to_next.connect(end_loot)
	$GameCore.continue_to_next.connect(lock_complete)
	$GameCore.continue_to_failure.connect(do_failure)
	$StrategyHub.continue_to_next.connect(end_strategy)
	$FailureScreen.continue_to_title.connect(end_game.emit)
	
	$MenuButton.pressed.connect($MenuMain.show_menu)
	$MenuMain.auto_complete_level.connect(auto_complete_level)
	$MenuMain.reveal_level.connect(reveal_level)
	$MenuMain.break_three.connect(break_three)

	# if name == "__main__:
	if get_tree().current_scene == self:
		begin_new_game(DeckTemplates.STANDARD.deck_gen.call())
