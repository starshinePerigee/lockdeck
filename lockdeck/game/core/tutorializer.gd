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

static var BREAK_SPIKE_DECK := LockDeck.from_template_array(
	[
		DepthTemplates.BREAK,
		DepthTemplates.SPIKE
	]
)

static var REVEAL_DECK: Array[CardSpec] = [
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
	CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_1),
	CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_1),
	CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_1),
]

static var CHALLENGE_6 := StateSpec.new(
	AllCardsSpec.new(REVEAL_DECK),
	LockSpec.new(
		[
			PinSpec.from_depth_array(
				[
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.WARN,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.BREAK,
					Depths.EMPTY,
				]
			),
		],
		BREAK_SPIKE_DECK
	)
)

static var CHALLENGE_7 := StateSpec.new(
	AllCardsSpec.new(REVEAL_DECK),
	LockSpec.new(
		[
			PinSpec.from_depth_array(
				[
					Depths.WARN,
					Depths.BREAK,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.EMPTY,
				]
			),
			PinSpec.from_depth_array(
				[
					Depths.EMPTY,
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.WARN,
					Depths.EMPTY,
					Depths.BREAK,
				]
			),
		],
		BREAK_SPIKE_DECK
	)
)

static var DEPTH_DEMO: Array[Depths] = [
	Depths.EMPTY,
	Depths.EMPTY,
	Depths.WARN,
	Depths.EMPTY,
	Depths.BREAK,
	Depths.EMPTY,
	Depths.SPIKE,
]

static var WARN_EMPTY_BREAK: Array[Depths] = [
	Depths.WARN,
	Depths.EMPTY,
	Depths.BREAK
]

static var TUTORIAL_4 := StateSpec.new(
	AllCardsSpec.new(
		[]
	),
	LockSpec.new([PinSpec.from_depth_array(DEPTH_DEMO)], BREAK_SPIKE_DECK)
) 

static var TEST_DECK: Array[CardSpec] = [
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_TEST_3),
	CardSpec.from_template(PickTemplates.TUTORIAL_TEST_3),
	CardSpec.from_template(PickTemplates.TUTORIAL_DIAMOND),
	CardSpec.from_template(PickTemplates.TUTORIAL_DIAMOND),
	CardSpec.from_template(PickTemplates.TUTORIAL_TEST_1),
	CardSpec.from_template(PickTemplates.TUTORIAL_TEST_1),
	CardSpec.from_template(PickTemplates.TUTORIAL_TEST_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_TEST_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_TEST_3_FLAT),
	CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_1),
	CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_2),
	CardSpec.from_template(PickTemplates.TUTORIAL_WEIRD_DARK),
]

static var CHALLENGE_8 := StateSpec.new(
	AllCardsSpec.new(TEST_DECK),
	LockSpec.new(
		[
			PinSpec.from_depth_array(
				[
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.WARN,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.BREAK,
					Depths.EMPTY,
				]
			),
		],
		SPIKE_DECK
	)
)

static var CHALLENGE_9 := StateSpec.new(
	AllCardsSpec.new(TEST_DECK),
	LockSpec.new(
		[
			PinSpec.from_depth_array(
				[
					Depths.EMPTY,
					Depths.WARN,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.SPIKE,
					Depths.BREAK,
					Depths.EMPTY,
				]
			),
		],
		SPIKE_DECK
	)
)

static var CHALLENGE_10 := StateSpec.new(
	AllCardsSpec.new(TEST_DECK),
	LockSpec.new(
		[
			PinSpec.from_depth_array(
				[
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.WARN,
					Depths.BREAK,
					Depths.EMPTY,
				]
			),
			PinSpec.from_depth_array(
				[
					Depths.WARN,
					Depths.EMPTY,
					Depths.BREAK,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.EMPTY,
				]
			),
		],
		SPIKE_DECK
	)
)

static var CHALLENGE_11 := StateSpec.new(
	AllCardsSpec.new(TEST_DECK),
	LockSpec.new(
		[
			PinSpec.from_depth_array(
				[
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.WARN,
					Depths.EMPTY,
					Depths.EMPTY,
					Depths.BREAK,
					Depths.EMPTY,
				]
			),
			PinSpec.from_depth_array(
				[
					Depths.WARN,
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.SPIKE,
					Depths.EMPTY,
					Depths.BREAK,
					Depths.EMPTY,
				]
			),
		],
		SPIKE_DECK
	)
)



const TUTORIAL := LevelSpec.Stages.TUTORIAL
const SPECIFIC := LevelSpec.Stages.SPECIFIC

static var TUTORIAL_SEQUENCE: Array[LevelSpec] = [
	LevelSpec.new(TUTORIAL),  # disregarded - tutorial starts at 1
	LevelSpec.new(TUTORIAL, 0, 0, TUTORIAL_1, LevelSpec.InterfaceSetup.FULL_EMPTY),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_1, LevelSpec.InterfaceSetup.HALF_SHOWN),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_2, LevelSpec.InterfaceSetup.HALF_SHOWN),
	LevelSpec.new(TUTORIAL, 1, 0, TUTORIAL_2, LevelSpec.InterfaceSetup.HALF_SHOWN),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_3, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_4, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_5, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(TUTORIAL, 2, 0, TUTORIAL_3, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_6, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_7, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(TUTORIAL, 3, 0, TUTORIAL_4, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_8, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_9, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_10, LevelSpec.InterfaceSetup.THREE_QUARTERS),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_11, LevelSpec.InterfaceSetup.THREE_QUARTERS),
]

func tutorialize(level_: int) -> void:
	level = level_
	step = 0
	if level == 3:
		step = 32
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
					core.tutorial_lock(true)
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
						+ "You see how there's two of them? That means this pick pushes the pin up two.",
						550,
						250
					)
				10:
					show_box(
						"If you forget, you can hover over any of your picks "
						+ "and get a quick reminder about what they do.\n\n"
						+ "That applies to just about anything you see - so don't forget it!"
					)
				11:
					show_box(
						"Go ahead and use the pick on the pin. Either click and drag it over, "
						+ "or click it once, and then click on the pin. No difference either way.",
						550,
						250,
						false
					)
					core.tutorial_lock(false)
					await_use = 1
				12:
					core.tutorial_lock(true)
					show_box(
						"Good work. See how the pin moved up two spaces?\n\n"
						+ "We call those spaces depths. Each pin has eight depths, plus the base "
						+ "depth at the top. So you need eight pushes to unlock a lock.",
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
					core.get_node("DeckMain").add_cards(new_cards)
					core.draw_to_five()
				14:
					core.tutorial_lock(false)
					show_box("Have at it.", 370, 180, false)
					await_unlock = 1
				15:
					core.tutorial_lock(true)
					show_box(
						"Nice work.\n\n"
						+ "Don't sweat the green 'ok', the little purple waves, " 
						+ "or any other icons that haven't been explained yet. "
						+ "Lockpicking is complicated - we'll get there. You just gotta take it step by step."
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
						"This is your deck. This is where you keep all the picks you haven't used yet.",
						64,
						300,
					)
				19:
					show_box(
						"You can click the 'Deck' button to see all the cards currently in it.",
						64,
						300,
						false
					)
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
					show_box(
						"Pick this lock again, and watch how your cards move.",
						PIN_X,
						PIN_Y,
						false
					)
					core.tutorial_lock(false)
					await_unlock = 1
				26:
					core.tutorial_lock(true)
					show_box("Perfect. Two more things before I let you go for the day.")
				27:
					core.get_node("AnimationPlayer").play("show_trash")
					var t := create_tween()
					t.tween_interval(0.5)
					t.tween_callback(advance)
				28:
					highlight(core.get_node("TrashMain").get_global_rect().grow(6))
					show_box(
						"This is your trash pile. "
						+ "If you screw up and break picks, they end up here instead of in your discard.\n\n"
						+ "Broken picks are gone until you can repair them, which might be a bit and costs money.",
						400,
						210,
					)
				29:
					highlight(core.get_node("TrashMain").get_global_rect().grow(6))
					show_box(
						"Of course, right now we're training, so you don't need to worry about money or repairs just yet.",
						400,
						210,
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
					await draw_cards([
						PickTemplates.TUTORIAL_PUSH_2,
						PickTemplates.TUTORIAL_PUSH_2,
						PickTemplates.TUTORIAL_PUSH_1,
						PickTemplates.TUTORIAL_PUSH_1,
						PickTemplates.TUTORIAL_PUSH_3,
						PickTemplates.TUTORIAL_PUSH_3,
						PickTemplates.TUTORIAL_PUSH_3,
					])
					core.tutorial_lock(false)
				33:
					if core.get_node("TrashMain").count() > 0:
						core.tutorial_lock(true)
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
					core.tutorial_lock(false)
					show_box(
						"Now click the candle twice to end your turn.",
						380,
						100,
						false
					)
					core.get_node("LockBody/CountdownMain").button_disable = false
					await core.turn_ended
					advance()
				45:
					core.tutorial_lock(true)
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
					core.tutorial_lock(false)
					core.continue_to_next.emit()
		1:
			match step:
				0:
					core.tutorial_lock(true)
					core.get_node("LockBody/CountdownMain").button_disable = true
					core.set_discard_disable(true)
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
					core.tutorial_lock(true)
					show_box(
						"Fun, isn't it!\n\n"
						+ "Spike will break your pick if you land on it.",
						PIN_X,
						140,
					)
				7:
					show_box(
						"Pay attention to how it's turned grey. "
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
					await draw_cards([
						PickTemplates.TUTORIAL_PUSH_1,
						PickTemplates.TUTORIAL_PUSH_1,
						PickTemplates.TUTORIAL_PUSH_3,
						PickTemplates.TUTORIAL_PUSH_3
					])
					core.tutorial_lock(false)
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
					core.tutorial_lock(true)
					show_box(
						"If you really need a specific pick, you can keep discarding until you find it.\n\n"
						+ "But don't forget to keep an eye on your candle. Each pick discarded is a pick you don't get "
						+ "to use this turn."
					)
				20:
					core.tutorial_lock(false)
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
						+ "this button here will let you see what went down last time you did something.\n\n"
						+ "It's also useful if you just need to see the whole lock.",
						200,
						40,
						false
					)
					await_prev = true
				23:
					show_box(
						"Don't worry too much about all the different icons. "
						+ " You'll learn what they mean in time.\n\n"
						+ "Click the button again to go back.",
						350,
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
						80,
						94,
						false
					)
					await core.get_node("DepthButton").pressed
					advance()
				26:
					show_box(
						"This practice lock is simple, but real locks will have a lot more depths.\n\n"
						+ "Don't hesitate to check what depths you're up against, and if you need a refresher on "
						+ "what a specific depth does you can hover over it in this depths window.\n\n"
						+ "Close the depths reference to continue.",
						280,
						220,
						false
					)
					await core.get_node("DepthDisplay").closed
					advance()
				27:
					show_box(
						"The next couple of locks are going to be full of spikes. Like before, pick them without "
						+ "breaking any picks to continue.\n\n"
						+ "You'll need to be capable and clever - prove to me you're both."
					)
				28:
					core.tutorial_lock(false)
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
						"Somewhere in this pin is a \"Break\" depth. Like spikes, if you "
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
						"But break is the most common hazard you'll find. Every single pin has exactly one "
						+ "break depth somewhere.\n\n"
						+ "That means every pin also has exactly one warning depth.",
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
						"There you go! The break depth.\n\nThe problem with warning depths is they only tell you that a "
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
						CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_2),
					]
					core.get_node("DeckMain").load_cards(one_reveal)
					core.draw_to_five()
					await core.animation_complete
					advance()
				12:
					highlight(Rect2(Vector2(462, 412), Vector2(24, 42)).grow(6))
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
						CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2)
					]
					core.get_node("HandMain").add_cards(new_hand)
					var new_deck: Array[CardSpec] = [
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
					core.tutorial_lock(true)
					await_use = 0
					await_break = 0
					if core.get_node("TrashMain").count() > 0:
						step = 15
						show_box("The point is to not break picks. Try again, dumbass.")
					elif core.get_node("DiscardMain").count() > 0:
						var template: PickTemplates = core.get_node("DiscardMain").cards[-1].template
						if template == PickTemplates.TUTORIAL_REVEAL_2:
							step = 15
							show_box(
								"Reveal picks are valuable, and you kind of wasted that one.\n\n"
								+ "There's always a warning before a break, so you know there's a safe depth "
								+ "on the other side of the spikes. Try again."
							)
						elif template == PickTemplates.TUTORIAL_PUSH_2:
							show_box(
								"Nice. You know it's safe becasue you haven't found the "
								+ "warning yet, and you know the spike isn't it.",
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
					core.tutorial_lock(false)
					show_box(
						"Keep going, and be as safe as you can.",
						PIN_X,
						PIN_Y,
						false 
					)
					await_use = 1
					await_break = 1
				20:
					core.tutorial_lock(true)
					await_use = 0
					await_break = 0
					if core.get_node("TrashMain").count() > 0:
						step = 15
						show_box("how")
					elif core.get_node("DiscardMain").count() > 0:
						var template: PickTemplates = core.get_node("DiscardMain").cards[-1].template
						if template == PickTemplates.TUTORIAL_REVEAL_2:
							step = 15
							show_box(
								"Reveal picks are valuable, and you kind of wasted that one?\n\n"
								+ "There's always a warning before a break, and you haven't found the warning yet, "
								+ "so you know the very next depth has to be safe."
							)
						elif template == PickTemplates.TUTORIAL_PUSH_1:
							show_box(
								"Nice. There's only one depth that's definitely safe, becuase there has to " 
								+ "be a warning somewhere.",
							)
						else:
							step = 15
							show_box(
								"You only know exactly one depth is safe, because you haven't "
								+ "found the warning yet. You got lucky this time, but you could have "
								+ "landed on a break. Try again."
							)
					else:
						step = 15
						show_box("Stop being dumb.")
				21:
					core.tutorial_lock(false)
					show_box(
						"Keep going.",
						PIN_X,
						PIN_Y,
						false 
					)
					await_use = 1
					await_break = 1
				22:
					core.tutorial_lock(true)
					await_use = 0
					await_break = 0
					if core.get_node("TrashMain").count() > 0:
						step = 15
						show_box(
							"This is why you don't push blindly! At least now you know where the break is.\n\n"
							+ "Try again."
						)
					elif core.get_node("DiscardMain").count() > 0:
						var template: PickTemplates = core.get_node("DiscardMain").cards[-1].template
						if template == PickTemplates.TUTORIAL_REVEAL_2:
							show_box(
								"Correct.\n\nNow that you can't be sure what's ahead, it was finally time "
								+ "to use that reveal pick. Now you know where the break is."
							)
						else:
							step = 15
							show_box(
								"You have no way of knowing where the break is, and no safe depths, so "
								+ "pushing forward is risky. Right now, we're trying to avoid risk. Try again."
							)
					else:
						step = 15
						show_box("Stop being dumb.")
				23:
					core.tutorial_lock(false)
					show_box(
						"Two picks left.",
						PIN_X,
						PIN_Y,
						false 
					)
					await_use = 1
					await_break = 1
				24:
					core.tutorial_lock(true)
					await_use = 0
					await_break = 0
					if core.get_node("TrashMain").count() > 0:
						step = 15
						show_box(
							"Break, does in fact, break your pick. Stop being dumb and try again."
						)
					elif core.get_node("DiscardMain").count() > 0:
						var template: PickTemplates = core.get_node("DiscardMain").cards[-1].template
						if template == PickTemplates.TUTORIAL_PUSH_3:
							show_box(
								"You know where the break is, which means you know where the break isn't. "
								+ "That space after the break is safe! Now finish this off."
							)
						else:
							step = 15
							show_box("how")
					else:
						step = 15
						show_box("Stop being dumb.")
				25:
					core.tutorial_lock(false)
					await_unlock = 1
				26:
					core.tutorial_lock(true)
					show_box("Alright. That's reveal. One more thing today.")
				27:
					core.get_node("DeckMain").add_cards([
						CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_1)
					] as Array[CardSpec])
					core.draw_to_five()
					await core.animation_complete
					highlight(Rect2(Vector2(462, 412), Vector2(24, 52)).grow(6))
					show_box(
						"So far, all the picks you've used have had a single effect type. "
						+ "Most picks have a couple, like this one.",
						550,
						350
					)
				28:
					show_box(
						"Pick effects trigger from the top down. For this pick, it'll push one depth, "
						+ "and then reveal one depth.\n\n"
						+ "If you need a reference, drag the pick over a pin without letting go, or click the pick "
						+ "and then hover over the pin. If you see purple icons, don't worry about them yet - "
						+ "we'll talk about those next time.",
						550,
						250
					)
				29:
					reset_pins([PinSpec.from_depth_array([
						Depths.EMPTY,
						Depths.EMPTY,
						Depths.WARN,
						Depths.BREAK,
						Depths.EMPTY,
						Depths.EMPTY,
						Depths.SPIKE,
					] as Array[Depths])])
					core.get_node("DeckMain").add_cards([
						CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_REVEAL_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
					] as Array[CardSpec])
					core.draw_to_five()
					show_box(
						"It's probably best to see for yourself.\n\n"
						+ "I've given you some picks to play around with. Solve this without "
						+ "breaking a pick and I'll let you go.\n\n"
						+ "Don't forget you can end your turn to reset the pin and your picks.",
						PIN_X,
						PIN_Y - 50,
					)
				30:
					core.set_discard_disable(false)
					core.get_node("LockBody/CountdownMain").button_disable = false
					core.tutorial_lock(false)
					await_break = 1
					await_unlock = 2
				31:
					step = 28
					show_box("Gotcha! Try again and pay attention to how you're revealing depths.")
				32:
					show_box("Nice. Go pick the next couple locks without breaking any of my picks.")
				33:
					core.continue_to_next.emit()
		3:
			match step:
				0:
					core.tutorial_lock(true)
					core.set_discard_disable(true)
					core.get_node("LockBody/CountdownMain").button_disable = true
					show_box("Glad to see you back.")
				1:
					show_box("Before we talk about the next kind of pick, let's review.")
				2:
					core.reveal_lock()
					show_box("Here's every depth you've seen so far.")
				3:
					highlight(Rect2(Vector2(210, 152), Vector2(94, 80)))
					show_box(
						"Empty depths and warning depths are both safe. "
						+ "You can land on them with no problems.",
						PIN_X,
						148
					)
				4:
					highlight(Rect2(Vector2(210, 248), Vector2(94, 48)))
					show_box(
						"Break is dangerous. "
						+ "If you land on it, you break your pick.",
						PIN_X,
						236
					)
				5:
					highlight(Rect2(Vector2(210, 312), Vector2(94, 48)))
					show_box(
						"Spike is also dangerous, but it's revealed at the start.",
						PIN_X,
						300
					)
				6:
					show_box(
						"The core of lockpicking is about finiding the hidden break depth and not landing on it.\n\n"
						+ "You don't actually need reveal if you can ferret it out with more common picks."
					)
				7:
					await reset_pins([PinSpec.from_depth_array(DEPTH_DEMO)])
					advance()
				8:
					await draw_cards([PickTemplates.TUTORIAL_TEST_2])
					advance()
				9:
					highlight(Rect2(Vector2(462, 412), Vector2(24, 42)).grow(6))
					show_box(
						"Meet \"test\", reveal's little brother."
						+ "\n\nYou might have seen it already.",
						480,
						280
					)
				10:
					core.tutorial_lock(false)
					show_box(
						"Go ahead and try it.",
						PIN_X,
						PIN_Y,
						false
					)
					await_use = 1
				11:
					core.tutorial_lock(true)
					show_box(
						"When you test a pin, you're feeling what's coming, but only broadly.\n\n"
						+ "Test tells you the worst danger from every depth you tested."
					)
				12:
					advance()
				13:
					highlight(Rect2(Vector2(210, 120), Vector2(94, 80)))
					show_box(
						"The pick you just played had two test icons, so it tested the first two "
						+ "depths in this pin. Since  "
						+ "safe.\n\n"
						+ "That's what these green \"ok\" marks indicate. These depths are definitely ok to activate.",
						PIN_X,
						PIN_Y
					)
				14:
					highlight(Rect2(Vector2(210, 120), Vector2(94, 80)))
					show_box(
						"They're not necessarily empty depths (warning tests as safe, for one) "
						+ "but you'll always be happy to see them.",
						PIN_X,
						PIN_Y
					)
				15:
					await draw_cards([PickTemplates.TUTORIAL_TEST_3])
					advance()
				16:
					show_box(
						"Picks that push and test together are going to be your bread and butter.\n\n"
						+ "They advance you up the pin and clear the way in one smooth action."
					)
				17:
					core.tutorial_lock(false)
					show_box(
						"You know the next couple depths are safe from your tests, so "
						+ "go ahead and use this pick.",
						PIN_X,
						PIN_Y,
						false
					)
					await_use = 1
				18:
					core.tutorial_lock(true)
					show_box(
						"Looks like danger ahead. However, not all of those depths marked X are bad!\n\n"
						+ "You tested the pin, and felt danger somewhere in that test - you just don't exactly where.",
						PIN_X,
						PIN_Y
					)
				19:
					show_box(
						"Since pins only have one break depth "
						+ "(and break is the only depth in this lock that tests as dangerous) "
						+ "only one of those depths is actually a threat.",
						PIN_X,
						PIN_Y
					)
				20:
					show_box(
						"If you're not sure about what depths are in the lock, or what each depth "
						+ "tests as, you can check the depths in the depths reference. Hover over them and " 
						+ " the top right corner of the tooltip will tell you what they test as."
					)
				21:
					highlight(Rect2(Vector2(210, 120), Vector2(94, 112.0)))
					show_box(
						"Anyway, one of these three depths is the break. You could risk it - "
						+ "one in three ain't the worst odds - but that's still not ideal.",
						PIN_X,
						PIN_Y
					)
				22:
					highlight(Rect2(Vector2(210, 216), Vector2(94, 48)))
					show_box(
						"If you had a pick that pushed four, you'd be set.\n\nSince break depth is "
						+ "in one of the three depths marked dangerous, you know it can't be here.",
						PIN_X,
						PIN_Y
					)
				23:
					show_box(
						"But four-pushers are pretty hard to come by and have all kinds of quirks.\n\n"
						+ "Instead, we're going to have to do a bit more testing."
					)
				24:
					await draw_cards([PickTemplates.TUTORIAL_TEST_2])
					advance()
				25:
					core.tutorial_lock(false)
					show_box(
						"Re-test two of those depths.",
						PIN_X,
						PIN_Y,
						false
					)
					await_use = 1
				26:
					show_box(
						"Bingo. You've cleared two of those depths, so - by process of elimination - "
						+ "you now know exactly where the break is. Finishing this lock is now child's play.",
						PIN_X,
						PIN_Y
					)
				27:
					await draw_cards([
						PickTemplates.TUTORIAL_PUSH_1,
						PickTemplates.TUTORIAL_PUSH_1,
						PickTemplates.TUTORIAL_PUSH_2,
						PickTemplates.TUTORIAL_PUSH_2,
					])
					show_box(
						"That's why I'll let you finish this lock.",
						PIN_X,
						PIN_Y,
						false,
					)
					await_break = 1
					await_unlock = 2
				28:
					core.tutorial_lock(true)
					show_box("I thought you were better than that. Moving on...")
					advance()
				29:
					show_box(
						"There's a few more things to learn about test."
					)
					core.tutorial_lock(true)
					await_break = 0
					await_unlock = 0
					empty_cards()
					reset_pins([PinSpec.from_depth_array()])
				30:
					show_box(
						
							"First, when you use a push pick with more than one push, you test every depth "
							+ "you skip over."
					)
				31:
					show_box(
						"That can be a little annoying when you jump a depth, but when you're testing, "
						+ "you're testing based on feel, so it all gets kind of mixed up. Only reveal picks let "
						+ "you tell apart individual depths."
					)
				32:
					core.tutorial_lock(false)
					show_box("Let's demonstrate. Use that pick.", PIN_X, PIN_Y, false)
					draw_cards([PickTemplates.TUTORIAL_DIAMOND])
					reset_pins([PinSpec.from_depth_array([
						Depths.WARN,
						Depths.BREAK,
						Depths.EMPTY,
						Depths.EMPTY
					])])
					await_use = 1
				33:
					core.tutorial_lock(true)
					show_box(
						"You could have skipped the break - or it could be ahead of you.\n\n"
						+ "You have no way of knowing. Let's see what's under the curtain...",
						PIN_X,
						PIN_Y
					)
				34:
					core.reveal_lock()
					show_box("Looks like it was behind you this time.", PIN_X, PIN_Y)
				35:
					show_box(
						"Second quick lesson. Depths that are revealed don't count for test.\n\n"
						+ "You already know it's there, so you can ignore it when you're feeling out the pin."
					)
				36:
					show_box(
						"This goes for both depths that are revealed before your pick, "
						+ "and depths that are revealed by your pick."
					)
				37:
					var test_pin := PinSpec.from_depth_array([
						Depths.EMPTY, # push
						Depths.WARN, # push
						Depths.EMPTY, # reveal
						Depths.EMPTY, # reveal
						Depths.BREAK, # test
						Depths.EMPTY, # test
					])
					for i in [4, 5]:
						test_pin.reveals[i] = PinSpec.RevealLevel.REVEALED 
					reset_pins([test_pin])
					await core.animation_complete
					advance()
				38:
					highlight(Rect2(Vector2(210, 216), Vector2(94, 80)))
					show_box(
						"Here's another demonstration. Two depths are already revealed in this lock. "
					)
				39:
					await draw_cards([PickTemplates.TUTORIAL_WEIRD_DARK])
					core.tutorial_lock(false)
					show_box(
						"Go ahead and use that pick, but also pay attention " 
						+ "to the preview icons right before you play it.", 
						PIN_X,
						PIN_Y,
						false
					)
					await_use = 1
				40:
					core.tutorial_lock(true)
					show_box(
						"Despite the break being one of the tested depths, this pick tested as safe.\n\n"
						+ "That's becasue only two depths were tested - every other depth was revealed, "
						+ "one way or another.",
						PIN_X,
						PIN_Y
					)
				41:
					show_box(
						"If you want to check what actually got tested last turn, click \"show previous\" "
						+ "and look for the test icons. Go ahead and do it now.",
						-1,
						-1,
						false
					)
					await_prev = 1
				42:
					await_prev = 1
				43:
					reset_pins([PinSpec.from_depth_array(WARN_EMPTY_BREAK)])
					await core.animation_complete
					advance()
				44:
					show_box(
						"Last lesson. If you re-test a depth, it'll only update if you can mark it safer. "
					)
				45:
					show_box(
						"You saw that earlier, but we'll do it again."
					)
				46:
					core.reveal_lock()
					highlight(Rect2(Vector2(210, 184), Vector2(94, 48)))
					show_box(
						"For the rest of these examples, break will be right here every time.",
						PIN_X,
						PIN_Y
					)
				47:
					reset_pins([PinSpec.from_depth_array(WARN_EMPTY_BREAK)])
					await core.animation_complete
					draw_cards([PickTemplates.TUTORIAL_TEST_2])
					advance()
				48:
					core.tutorial_lock(false)
					show_box("Go ahead.", PIN_X, PIN_Y, false)
					await_use = 1
				49:
					core.tutorial_lock(true)
					await draw_cards([PickTemplates.TUTORIAL_TEST_3_FLAT])
					show_box(
						"This next pick will test all three depths, and that includes the break. "
						+ "But it's not going to update the first two - you already know they're safe, "
						+ "so they can't be dangerous. Right?",
						PIN_X,
						PIN_Y
					)
				50:
					core.tutorial_lock(false)
					show_box("Give it a go.", PIN_X, PIN_Y, false)
					await_use = 1
				51:
					core.tutorial_lock(true)
					show_box("Just as predicted. Let's do it the other way now.", PIN_X, PIN_Y)
				52:
					await reset_pins([PinSpec.from_depth_array(WARN_EMPTY_BREAK)])
					await draw_cards([PickTemplates.TUTORIAL_TEST_3_FLAT])
					core.tutorial_lock(false)
					await_use = 1
					show_box("Long one first...", PIN_X, PIN_Y, false)
				53:
					await draw_cards([PickTemplates.TUTORIAL_TEST_2])
					await_use = 1
					show_box("Then the short one.", PIN_X, PIN_Y, false)
				54:
					core.tutorial_lock(true)
					show_box("See how this time around, it updated? Danger is less specific than safe, so they updated. "
					+ "Simple as.",
					PIN_X, PIN_Y)
				56:
					show_box("Oh, I lied when I said last lesson. One more.")
				57:
					show_box("If you break or reveal past the end of a pin, you won't break the pick "
					+ "the same way you would if you push past the end of a pin.")
				58:
					show_box("No demonstration. Test it for yourself if you don't trust me.")
				59:
					show_box("Anyway, I'm tired of talking. Go practice on your own until you understand testing locks.")
				60:
					show_box("And don't break my picks!")
				61:
					core.continue_to_next.emit()



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

func draw_cards(templates: Array[PickTemplates]) -> void:
	var specs: Array[CardSpec] = []
	for template in templates:
		specs.append(CardSpec.from_template(template))
	core.get_node("DeckMain").load_cards(specs)
	core.draw_to_five()
	await core.animation_complete

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
