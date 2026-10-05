extends Control
## Tutorializer is a scene used to display tutorial info such as a popup and hint arrows.
## It also manages demo logic, working with game manager and game spec to step through tutorials.
class_name Tutorializer

# Tutorial logic:
# on tutorial start, we enter the tutorial state and create a game that's in the tutorial mode.
# game spec's tutorial level array manages TUTORIAL levelspecs and SPECIFIC levelspecs

# These static vars are pulled into gamespec but this class also serves as a sort of hub for logic

var core: GameCore:
	set(v):
		core = v
		core.new_state.connect(pick_used)
		core.pick_broke.connect(pick_broken)
		core.game_win.connect(lock_unlocked)
		core.get_node("PreviousButton").show_previous.connect(prev_preved)
		core.get_node("PreviousButton").go_back.connect(prev_preved)
		core.get_node("CardDisplay").closed.connect(display_closed)
		
var level: int
var step: int

static var TUTORIAL_1 := StateSpec.new(
	AllCardsSpec.new(),
	LockSpec.new(
		[
			PinSpec.from_depth_array()
		]
	)
) 

static var TWO_OF_EACH: Array[CardSpec] = [
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
]

static var CHALLENGE_1 := StateSpec.new(
	AllCardsSpec.new(TWO_OF_EACH),
	LockSpec.new(
		[
			PinSpec.from_depth_array([])
		]
	)
)

static var PUSHY_DECK: Array[CardSpec] = [
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
]

static var CHALLENGE_2 := StateSpec.new(
	AllCardsSpec.new(PUSHY_DECK),
	LockSpec.new(
		[
			PinSpec.from_depth_array([]),
			PinSpec.from_depth_array([])
		]
	)
)

static var TWO_SPIKES: Array[Depths] = [
	Depths.EMPTY,
	Depths.SPIKE,
	Depths.EMPTY,
	Depths.EMPTY,
	Depths.EMPTY,
	Depths.SPIKE,
]

static var SPIKE_DECK := LockDeck.from_template_array([DepthTemplates.SPIKE])

static var TUTORIAL_2 := StateSpec.new(
	AllCardsSpec.new(
		[
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2)
		]
	),
	LockSpec.new([PinSpec.from_depth_array(TWO_SPIKES)], SPIKE_DECK)
) 

static var CHALLENGE_3 := StateSpec.new(
	AllCardsSpec.new(PUSHY_DECK),
	LockSpec.new(
		[
			PinSpec.from_depth_array(
				[
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.SPIKE,
				]
			),
		],
		SPIKE_DECK
	),
)

static var CHALLENGE_4 := StateSpec.new(
	AllCardsSpec.new(PUSHY_DECK),
	LockSpec.new(
		[
			PinSpec.from_depth_array(
				[
					Depths.EMPTY,
					Depths.SPIKE,
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.SPIKE,
				]
			),
		],
		SPIKE_DECK
	)
)

static var CHALLENGE_5 := StateSpec.new(
	AllCardsSpec.new(
		[
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
		]
	),
	LockSpec.new(
		[
			PinSpec.from_depth_array(
				[
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.SPIKE,
					Depths.EMPTY,
				]
			),
			PinSpec.from_depth_array(
				[
					Depths.SPIKE,
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.SPIKE,
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.SPIKE,
				]
			),
		],
		SPIKE_DECK
	)
)

static var EARLY_WARNING: Array[Depths] = [
	Depths.EMPTY,
	Depths.WARN,
	Depths.EMPTY,
	Depths.EMPTY,
	Depths.EMPTY,
	Depths.BREAK,
]

static var SPIKE_WARNING: Array[Depths] = [
	Depths.SPIKE,
	Depths.EMPTY,
	Depths.WARN,
	Depths.EMPTY,
	Depths.EMPTY,
	Depths.BREAK,
]

static var BREAK_DECK := LockDeck.from_template_array([DepthTemplates.BREAK])

static var TUTORIAL_3 := StateSpec.new(
	AllCardsSpec.new(
		[
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
		]
	),
	LockSpec.new([PinSpec.from_depth_array(EARLY_WARNING)], SPIKE_DECK)
) 

const TUTORIAL := LevelSpec.Stages.TUTORIAL
const SPECIFIC := LevelSpec.Stages.SPECIFIC

static var TUTORIAL_SEQUENCE: Array[LevelSpec] = [
	LevelSpec.new(TUTORIAL, 0, 0, TUTORIAL_1, LevelSpec.InterfaceSetup.FULL_EMPTY),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_1, LevelSpec.InterfaceSetup.HALF_SHOWN),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_2, LevelSpec.InterfaceSetup.HALF_SHOWN),
	LevelSpec.new(TUTORIAL, 1, 0, TUTORIAL_2, LevelSpec.InterfaceSetup.HALF_SHOWN),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_3, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_4, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_5, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(TUTORIAL, 2, 0, TUTORIAL_3, LevelSpec.InterfaceSetup.THREE_QUARTERS)
]

func tutorialize(level_: int) -> void:
	level = level_
	step = 0
	if level == 0:
		step = 46
	if level == 1:
		step = 13
	if level == 2:
		step = 16
	core.tutorial_mode = true
	core.get_node("LockBody/CountdownMain").set_count(999999)
	core.get_node("LockBody/CountdownMain").suggest = false

const PIN_X := 320
const PIN_Y := 166

func do_step() -> void:
	print("Tutorial Level %s Step %s" % [level, step])
	match level:
		0:
			match step:
				0:
					show_box(
						"Hey, kid. We caught you trying to pick locks without a licence.\n\n"
						+ "The Thieves' Guild doesn't take too kindly to that."
					)
				1:
					show_box(
						"Still. Maybe I'm taking after the old man, but someone as scrawny "
						+ "and wretched as you... You can't help but feel bad for strays.\n\n"
						+ "Besides, I have a job for someone dumb and reckless.\n\n"
						+ "Welcome to the Thieves' Guild, kid."
					)
				2:
					show_box(
						"That means you gotta learn to lockpick, and you gotta learn fast.\n\n"
						+ "So listen up!"
					)
				3:
					show_box(
						"You probably noticed already, but this is a lock.",
						468,
						154, 
					)
				4:
					show_box(
						"This lock has a single pin in it.",
						PIN_X,
						PIN_Y,
					)
					var pin: Control = core.get_node(
						"LockBody/CylinderMain/Cylinders/CylinderHBox/Pin1"
					)
					highlight(pin.get_global_rect().grow(6))
				5:
					show_box(
						"Push all the pins all the way up to unlock a lock. Simple as.",
						PIN_X,
						PIN_Y,
					)
				6:
					show_box(
						"Let's get you a pick."
					)
				7:
					core.get_node("HandMain").add_card(
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2)
					)
					core.tutorial_lock(true)
					await core.animation_complete
					var card: Control = core.get_node("HandMain/Hand/Hand").get_child(0)
					highlight(card.get_global_rect().grow(6))
					show_box(
						"This is a pick. It's stored in a card, so you can keep a lot of them "
						+ "close at hand.",
						550,
						350
					)
				8:
					highlight(Rect2(Vector2(462, 412), Vector2(24, 40)).grow(6))
					show_box(
						"The most important thing about this pick is these icons here.\n\n"
						+ "These icons are the pick's effects. They're what happen if you use that "
						+ "pick on the lock.",
						550,
						250
					)
				9:
					highlight(Rect2(Vector2(462, 412), Vector2(24, 40)).grow(6))
					show_box(
						"This icon is 'push'. That means it pushes the pin up.\n\n"
						+ "You need to push a pin all the way up to unlock the lock, so you're going "
						+ "to see a lot of these.\n\n"
						+ "You see how there's two of them? That means this pick pushes the pin up two. Simple as.",
						550,
						250
					)
				10:
					show_box(
						"Go ahead and use the pick on the pin. Either click and drag it over, "
						+ "or click it once, and then click on the pin. No difference either way.",
						550,
						250,
						false
					)
					core.tutorial_lock(false)
					await_use = 1
				11:
					# deleted
					advance()
				12:
					show_box(
						"Good work. See how the pin moved up two spaces?\n\n"
						+ "We call those spaces depths. Each pin has eight depths, plus the resting "
						+ "depth at the top. So you need eight pushes to unlock a lock. \n\n"
						+ "Don't worry about the green 'ok' or the little green letters just yet - " 
						+ "we'll get there.",
						PIN_X,
						PIN_Y,
					)
				13:
					show_box(
						"You're already a quarter of the way there, so these should get you "
						+ "the rest of the way up.",
						PIN_X,
						PIN_Y,
					)
					var new_cards: Array[CardSpec] = [
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2)
					]
					core.get_node("HandMain").add_cards(new_cards)
				14:
					show_box("Have at it.", 370, 180, false)
					await_unlock = 1
				15:
					show_box(
						"Nice work.\n\n"
						+ "If you forget what any of the icons mean, you can hover over any of your picks "
						+ "and get a quick reminder. \n\nThat applies to just about everything - so don't forget it!"
					)
				16:
					show_box("Let's reset that...", -1, -1, false)
					await reset_pins([PinSpec.from_depth_array()])
					var t := create_tween()
					t.tween_interval(0.4)
					t.tween_callback(advance)
				17:
					show_box(
						"Alright. Let's talk about how picks flow when you're lockpicking."
					)
					var new_cards: Array[CardSpec] = [
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3)
					]
					core.get_node("DeckMain").load_cards(new_cards)
					core.get_node("DiscardMain").empty_deck()
					core.get_node("AnimationPlayer").play("show_deck_discard")
				18:
					highlight(core.get_node("DeckMain").get_nice_rect().grow(6))
					show_box(
						"This is your deck. This is where you keep all the picks you haven't used yet.\n\n"
						+ "You can the 'Deck' button to see all the cards currently in it.",
						64,
						272,
					)
				19:
					highlight(core.get_node("DeckMain/DeckLabel").get_global_rect().grow(6))
					await_display_close = 1
				20:
					show_box(
						"I've given you a couple of picks to get started.\n\n"
						+ "You'll be giving those back, so don't be too thankful."
					)
				21:
					show_box(
						"After you use a pick, if you have cards in your deck, you'll draw back "
						+ "up to three cards. Let's do that now."
					)
				22:
					core.draw_to_five()
					await core.animation_complete
					advance()
				23:
					var hand_rect: Rect2 = core.get_node("HandMain").get_global_rect()
					hand_rect = hand_rect.grow_individual(-128, 6, -126, 0)
					highlight(hand_rect)
					show_box(
						"This is your hand. We call it that, because these picks are in your hand, see? " 
						+ "All easy.\n\nYou can use any of the picks that are in your hand in any order.",
						256,
						200
					)
				24:
					highlight(core.get_node("DiscardMain/DiscardLabel").get_global_rect().grow(6))
					show_box(
						"This is your discard pile. Picks you use end up here, hopefully",
						490,
						356,
					)
				25:
					show_box("Pick this lock again, and watch how your cards move.")
				26:
					await_unlock = 1
				27:
					show_box("Perfect. Two more things before I let you go for the day.")
				28:
					core.get_node("AnimationPlayer").play("show_trash")
					var t := create_tween()
					t.tween_interval(0.5)
					t.tween_callback(advance)
				29:
					highlight(core.get_node("TrashMain").get_global_rect().grow(6))
					show_box(
						"This is your trash pile. "
						+ "If you screw up and break picks, they end up here instead of in your discard.\n\n"
						+ "Broken picks are gone until you can repair them, which might be a bit and costs money.",
						440,
						280,
					)
				30:
					highlight(core.get_node("TrashMain").get_global_rect().grow(6))
					show_box(
						"Try real hard to avoid breaking picks. "
						+ "This is the skill that separates master thieves from rookies about to meet the bad end "
						+ "of a town guard.",
						440,
						280,
					)
				31:
					show_box(
						"With these training locks, there's really only one way to break a pick: "
						+ "push the pin past its final spot. Slamming a pin like that will break the pick.\n\n"
						+ "It's not all bad though, you'll still set the pin and can unlock the lock."
					)
				32:
					show_box(
						"Have a few more picks. Solve this lock by overshooting the pin and breaking a pick.\n\n"
						+ "Don't worry, these training picks are all cheap garbage anyway.",
						370,
						-1,
						false
					)
					await_unlock = 1
					core.discard_hand()
					await core.animation_complete
					core.get_node("DiscardMain").empty_deck()
					await reset_pins([PinSpec.from_depth_array()])
					var new_cards: Array[CardSpec] = [
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
					]
					core.get_node("DeckMain").load_cards(new_cards)
					core.draw_to_five()
				33:
					if core.get_node("TrashMain").count() > 0:
						show_box("That pick is trashed! Now you know what not to do.")
					else:
						step = 30
						show_box(
							"Good work avoiding breaking the pick, but I need you to learn what "
							+ "it feels like. Try again, and make sure you don't accidentally unlock the lock "
							+ "without overshooting it this time."
						)
				34:
					show_box(
						"I've been doing a bit of slight of hand with your deck - "
						+ "adding and removing stuff from it, for the sake of the lesson.\n\n"
						+ "If you're sharp, you probably noticed. But that's not how stuff normally works."
					)
				35:
					highlight(core.get_node("DiscardMain/DiscardLabel").get_global_rect().grow(6))
					show_box(
						"See how all the picks you just used ended up in your discard?\n\n"
						+ "Well, except the one you broke.",
						380,
						356,
					)
				36:
					show_box(
						"Discarded picks aren't gone. Once you've used all the picks in your deck, "
						+ "you can reload them by ending your turn.\n\nIt looks like this."
					)
				37:
					core.discard_hand()
					await core.animation_complete
					core.reload_deck()
					await core.animation_complete
					core.draw_to_five()
					await core.animation_complete
					advance()
				38:
					show_box(
						"Notice that any cards you were keeping in your hand also get "
						+ "shuffled back at end of your turn, but the pick you broke stays broken."
					)
				39:
					show_box(
						"Ending your turn isn't free. Let me get your candle..."
					)
					core.get_node("LockBody/CountdownMain").button_disable = true
					core.get_node("AnimationPlayer").play("show_countdown")
				40:
					highlight(core.get_node("LockBody/CountdownMain").get_mouse_rect())
					show_box(
						"Your candle tracks how many turns you have left.\n\n"
						+ "Run out of turns, run out of time.",
						380,
						100,
					)
				41:
					show_box(
						"We're safe right now, so you have plenty of turns.\n\n"
						+ "But out in the field, you have exactly three turns per lock."
					)
				42:
					show_box(
						"It pays to be speedy:\n\n"
						+ "Finish a lock on the first turn and get a bonus.\n\n"
						+ "Finish a lock on the second turn, all's fine.\n\n"
						+ "In the third turn, you'll start breaking picks randomly, so wrap it up!\n\n"
						+ "If you don't finish after the third turn, it's over for you.",
						-1,
						64
					)
				43:
					show_box(
						"You can hover over the candle for a reminder of all the details."
					)
				44:
					show_box(
						"Now click the candle to end your turn.",
						380,
						100,
						false
					)
					core.get_node("LockBody/CountdownMain").button_disable = false
					await core.turn_ended
					advance()
				45:
					show_box(
						"Did you see how the pin reset?\n\n"
						+ "Unfortunately, you'll have to ease up on the lock to reload your deck. " 
						+ "This means all the pins will fall back to the beginning.\n\n"
						+ "Later, we'll learn a way to avoid losing progress when you end your turn."
					)
				46:
					show_box(
						"Anyway, You're on your own for a bit. Pick this next lock without "
						+ "breaking a pick and I'll continue your training."
					)
				47:
					core.continue_to_next.emit()
		1:
			match step:
				0:
					core.tutorial_lock(true)
					show_box(
						"Nice job! As you noticed, some locks have more than one pin.\n\n"
						+ "Rich bastards'll try anything to keep us out. That's why it's time to continue learning."
					)
				1:
					show_box(
						"Speaking of which, it's time we started to talk about depths."
					)
				2:
					show_box(
						"So far, you've only focused on pushing to the end of the pin.\n\n"
						+ "From now on, you're going to have to deal with the fact that locks have surprises built in."
					)
				3:
					show_box(
						"Whenever you push a pin, whatever depth you land on will \"activate\".\n\n"
						+ "Needless to say, when it activates it's probably not throwing you a party."
					)
				4:
					highlight(
						core.get_node(
							"LockBody/CylinderMain/Cylinders/CylinderHBox/Pin1/Stack/Depths"
						)
						.get_child(2)
						.get_global_rect()
					)
					show_box(
						"Your first depth is \"spike\".",
						PIN_X,
						140,
					)
				5:
					show_box(
						"Why don't you see what it does.", PIN_X, 140, false
					)
					core.tutorial_lock(false)
					await_use = 1
				6:
					show_box(
						"Fun, isn't it!\n\n"
						+ "Spike will break your pick if you land on it.",
						PIN_X,
						140,
					)
				7:
					show_box(
						"Pay attention to how it's changed color. "
						+ "Depths will only activate once per turn - although it's pretty rare when that matters.",
						PIN_X,
						140,
					)
				8:
					show_box(
						"The real challenge in lockpicking is navigating the traps "
						+ "that make up each lock. Each lock is different, so your approach has to "
						+ "be different too."
					)
				9:
					core.get_node("TrashMain").reset()
					var new_cards: Array[CardSpec] = [
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
					]
					core.get_node("DeckMain").load_cards(new_cards)
					core.draw_to_five()
					await core.animation_complete
					advance(2)
				10:
					# failure reset
					core.tutorial_lock(true)
					reset_pins([PinSpec.from_depth_array(TWO_SPIKES)])
					core.get_node("TrashMain").reset()
					core.get_node("DeckMain").clear_all()
					core.get_node("HandMain").remove_all_cards(true)
					core.get_node("DeckMain").load_cards(PUSHY_DECK)
					core.draw_to_five()
					await core.animation_complete
					advance()
					core.tutorial_lock(false)
				11:
					show_box(
						"Go ahead and finish this lock without breaking another pick.",
						PIN_X,
						140,
						false,
					)
					await_unlock = 1
				12:
					if core.get_node("TrashMain").count() == 0:
						show_box("Good job avoiding the spikes and avoiding overshoot.")
					else:
						step = 9
						show_box(
							"Nah, you have to avoid breaking a pick. Try again."
						)
				13:
					core.tutorial_lock(true)
					reset_pins([PinSpec.from_depth_array(TWO_SPIKES)])
					core.get_node("DeckMain").clear_all()
					core.get_node("HandMain").remove_all_cards(true)
					var new_hand: Array[CardSpec] = [
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
					]
					core.get_node("HandMain").add_cards(new_hand)
					var new_deck: Array[CardSpec] = [
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
					]
					core.get_node("DeckMain").load_cards(new_deck)
					await core.animation_complete
					advance()
				14:
					show_box(
						"Let's give you a couple more tools to help you navigate locks\n\n"
						+ "Starting with the ability to discard picks without using them."
					)
				15:
					show_box("Sometimes none of the picks you have in your hand are useful in that moment.")
				16:
					show_box(
						"Look at this situation: three copies of the same pick, and each of them "
						+ "would land you right on the spike.",
						PIN_X,
						140,
					)
				17:
					show_box(
						"Luckily, you don't have to use a pick. If you're in a bad spot, you can always "
						+ "discard one of the picks in your hand to draw another.",
						PIN_X,
						140,
					)
				18:
					core.tutorial_lock(false)
					core.set_discard_disable(false)
					highlight(core.get_node("DiscardMain/DiscardIcon").get_global_rect().grow(6))
					show_box(
						"If you drag a card over here, or click this space with a pick selected, "
						+ "you'll discard it. Do it now.",
						420,
						220,
						false
					)
					await_use = 1
				19:
					show_box(
						"If you really need a specific pick, you can keep discarding until you find it.\n\n"
						+ "But don't forget to keep an eye on your candle. Each pick discarded is a pick you don't get "
						+ "to use this turn."
					)
				20:
					show_box(
						"Before we get to the next tool, I need to you play a pick. " 
						+ "Doesn't matter which, just play it on the pin.",
						PIN_X,
						140,
						false
					)
					await_use = 1
				21:
					core.tutorial_lock(true)
					core.get_node("AnimationPlayer").play("show_show_prev")
					var t := create_tween()
					t.tween_interval(0.3)
					t.tween_callback(advance)
				22:
					highlight(core.get_node("PreviousButton").get_global_rect().grow(6))
					show_box(
						"If you ever forget what you're doing, or get surprised by something that happened, "
						+ "this button here will let you see what went down last time you did something.",
						200,
						40,
						false
					)
					await_prev = true
				23:
					show_box(
						"Click it again to go back.",
						200,
						40,
						false
					)
					await_prev = true
				24:
					core.get_node("AnimationPlayer").play("show_depth_button")
					var t := create_tween()
					t.tween_interval(0.4)
					t.tween_callback(advance)
				25:
					highlight(core.get_node("DepthButton").get_global_rect().grow(6))
					show_box(
						"This button shows you all the depths that could be present in the current lock.",
						160,
						340,
						false
					)
					await core.get_node("DepthButton").pressed
					advance()
				26:
					show_box(
						"This practice lock is simple, but real locks will have a lot more depths.\n\n"
						+ "Don't hesitate to check what depths you're up against, and if you need a refresher on "
						+ "what a specific depth does you can hover over it in this depths window.\n\n"
						+ "Close the depths refernece to continue.",
						280,
						220,
						false
					)
					await core.get_node("DepthDisplay").closed
					advance()
				27:
					show_box(
						"The next couple of locks are going to be all spikes. Like before, pick them without "
						+ "breaking any picks to continue.\n\n"
						+ "You'll need to be capable and clever - prove to me you're both."
					)
				28:
					core.continue_to_next.emit()
		2:
			match step:
				0:
					core.tutorial_lock(true)
					core.set_discard_disable(true)
					show_box(
						"Looks like you're getting the hang of moving pins around. "
						+ "Time to reveal the other half of lockpicking."
					)
				1:
					show_box(
						"Somewhere in this pin is a \"Break\" depths. Like spikes, if you "
						+ "activate it it breaks your pick. Unlike spikes, they don't advertise themselves.",
						PIN_X,
						PIN_Y
					)
				2:
					core.tutorial_lock(false)
					show_box(
						"Why don't you see for yourself? Go ahead and unlock this lock.",
						PIN_X,
						PIN_Y,
						false
					)
					await_use = 1
				3:
					core.tutorial_lock(true)
					highlight(
						core.get_node(
							"LockBody/CylinderMain/Cylinders/CylinderHBox/Pin1/Stack/Depths"
						)
						.get_child(2)
						.get_global_rect()
					)
					show_box(
						"Did you feel that? That's a \"warning\" depth.\n\n"
						+ "Warning depths do nothing when you activate them, but they tell you the break is "
						+ "further down the pin. "
						+ "Every break depth has a warning. Break depths aren't total surprises.",
						PIN_X,
						PIN_Y,
					)
				4:
					show_box(
						"Know that when I say break depth, I mean the specific \"break\" depth.\n\n"
						+ "Spikes and other nasties don't get warnings.",
					)
				5:
					show_box(
						"But break is the most common hazard you'll find. Every single pin has a break depth somewhere.\n\n"
						+ "That means every pin also has a warning depth.",
					)
				6:
					core.tutorial_lock(false)
					show_box(
						"Let's finally get you introduced to the break depth. Keep going.",
						PIN_X,
						PIN_Y,
						false,
					)
					await_break = 1
				7:
					core.tutorial_lock(true)
					show_box(
						"Good.\n\nThe problem with warning depths is they only tell you that a "
						+ "break is somewhere below them.",
					)
				8:
					show_box(
						"That's not super useful, since every pin has a break depth!\n\n"
						+ "But until you meet your warning, know that you're safe.",
					)
				9:
					show_box(
						"Safe from break depths, at least.\n\nAgain - warning only cares about break, "
						+ "not any of the other hazards."
					)
				10:
					show_box(
						"You can't safely pick these locks right now with your current picks.\n\n"
						+ "I did say they were trash.\n\n"
						+ "Give me a moment to give you a new kind of pick."
					)
				11:
					core.tutorial_lock(true)
					reset_pins([PinSpec.from_depth_array(EARLY_WARNING)])
					core.get_node("DeckMain").clear_all()
					core.get_node("HandMain").remove_all_cards(true)
					var one_reveal: Array[CardSpec] = [
						CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_3),
					]
					core.get_node("DeckMain").load_cards(one_reveal)
					core.draw_to_five()
					await core.animation_complete
					advance()
				12:
					highlight(Rect2(Vector2(462, 412), Vector2(24, 52)).grow(6))
					show_box(
						"This icon is \"reveal\". It does exactly what it says - reveals upcoming depths.",
						550,
						250
					)
				13:
					core.tutorial_lock(false)
					show_box(
						"Give it a whirl.",
						PIN_X,
						PIN_Y,
						false
					)
					await_use = 1
				14:
					core.tutorial_lock(true)
					show_box(
						"Unlike push, it doesn't move the pin forward.\n\n"
						+ "That's good because it means you don't activate a new depth, but bad becasue it doesn't help "
						+ "pick the lock. Every pick is different!"
					)
				15:
					show_box("Let's give you a more real example...")
				16:
					reset_pins([PinSpec.from_depth_array(SPIKE_WARNING)])
					empty_cards()
					var new_hand: Array[CardSpec] = [
						CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_3),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2)
					]
					core.get_node("HandMain").add_cards(new_hand)
					var new_deck: Array[CardSpec] = [
						CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_3),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3)
					]
					core.get_node("DeckMain").add_cards(new_deck, true)
					await core.animation_complete
					advance()
				17:
					core.tutorial_lock(false)
					show_box(
						"Let's see if you've been paying attention. Have at it.",
						PIN_X, 
						PIN_Y, 
						false
						)
					await_use = 1
					await_break = 1
				18:
					await_use = 0
					await_break = 0
					if core.get_node("TrashMain").count() > 0:
						step = 15
						show_box("The point is to not break picks. Try again, dumbass.")
					elif core.get_node("DiscardMain").count() > 0:
						var template: PickTemplates = core.get_node("DiscardMain").cards[-1].template
						if template == PickTemplates.TUTORIAL_PUSH_1:
							step = 15
							show_box(
								"Did you learn anything by doing that?\n\n"
								+ "There's always a warning before a break, so you know there's a safe depth "
								+ "on the other side of the spikes. Try again."
							)
						elif template == PickTemplates.TUTORIAL_PUSH_2:
							show_box(
								"Nice. You know it's safe becasue you haven't found the "
								+ "warning yet.\n\nKeep going."
							)
							core.get_node("DeckMain").add_cards([
								CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2)
							] as Array[CardSpec])
						else:
							step = 15
							show_box("how")
					else:
						step = 15
						show_box("Stop being dumb.")
				19:
					show_box("bleh")

func advance(n := 1) -> void:
	step += n
	do_step()

func show_box(
	text: String,
	origin_x: int = -1,
	origin_y: int = -1,
	continuable := true
):
	%TutorialBox.show_box(text, origin_x, origin_y, continuable)

func highlight(rect: Rect2) -> void:
	%HighlightRect.visible = true
	%HighlightRect.position = rect.position
	%HighlightRect.size = rect.size


func hide_all() -> void:
	%HighlightRect.visible = false
	%TutorialBox.visible = false
	%Arrows.visible = false

var await_use := 0
func pick_used(_state: StateSpec) -> void:
	if await_use:
		advance(await_use)
		await_use = 0

var await_unlock := 0
func lock_unlocked() -> void:
	if await_unlock:
		advance(await_unlock)
		await_unlock = 0

var await_break := 0
func pick_broken() -> void:
	if await_break:
		advance(await_break)
		await_break = 0

var await_prev := false
func prev_preved() -> void:
	if await_prev:
		await_prev = false
		advance(1)

var await_display_close := 0
func display_closed() -> void:
	if await_display_close:
		var t := create_tween()
		t.tween_interval(0.05)
		t.tween_callback(advance.bind(await_display_close))
		await_display_close = 0

func reset_pins(pins: Array[PinSpec]) -> void:
	if core.lock_complete:
		core.lock_complete = 0
		core.get_node("LockBody/AnimationPlayer").play_backwards("unlock")
	
	var cylinders: Control = core.get_node(
		"LockBody/CylinderMain/Cylinders"
	) 
	cylinders.animate_fall(pins)
	await core.animation_complete
	core.get_node("LockBody/CylinderMain").load_new_lock(
		LockSpec.new(pins)
	)

func empty_cards() -> void:
	core.get_node("DiscardMain").empty_deck()
	core.get_node("DeckMain").clear_all()
	core.get_node("TrashMain").reset()
	core.get_node("HandMain").remove_all_cards(true)

func continue_pressed() -> void:
	hide_all()
	advance()

func _ready() -> void:
	%TutorialBox.box_clicked.connect(continue_pressed)
