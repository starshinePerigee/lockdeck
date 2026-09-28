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
		core.game_win.connect(lock_unlocked)
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

static var CHALLENGE_1 := StateSpec.new(
	AllCardsSpec.new(
		[
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_1),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_3),
		]
	),
	LockSpec.new(
		[
			PinSpec.from_depth_array([])
		]
	)
)

const TUTORIAL := LevelSpec.Stages.TUTORIAL
const SPECIFIC := LevelSpec.Stages.SPECIFIC

static var TUTORIAL_SEQUENCE: Array[LevelSpec] = [
	LevelSpec.new(TUTORIAL, 0, 0, TUTORIAL_1),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_1),
	LevelSpec.new(TUTORIAL, 1, 0, TUTORIAL_1),
]

func tutorialize(level_: int) -> void:
	level = level_
	step = 0
	# debug logic
	if level == 0:
		step = 33
	
	core.tutorial_mode = true

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
						320,
						166
					)
					var pin: Control = core.get_node(
						"LockBody/CylinderMain/Cylinders/CylinderHBox/Pin1"
					)
					highlight(pin.get_global_rect().grow(6))
				5:
					show_box(
						"Push all the pins all the way up to unlock a lock. Simple as.",
						320,
						166
					)
				6:
					show_box(
						"Let's get you a pick."
					)
				7:
					core.get_node("HandMain").add_card(
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2)
					)
					core.lock_input(true)
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
				9:
					show_box(
						"Go ahead and use the pick on the pin. Either click and drag it over, "
						+ "or click it once, and then click on the pin. No difference either way.",
						550,
						250
					)
				10:
					core.lock_input(false)
					await_use = 1
				11:
					show_box(
						"Good work. See how the pin moved up two spaces?\n\n"
						+ "We call those spaces depths. Each pin has eight depths, plus the resting "
						+ "depth at the top. So you need eight pushes to unlock a lock. \n\n"
						+ "Don't worry about the green 'ok' or the little green letters just yet - " 
						+ "we'll get there.",
						320,
						166
					)
				12:
					show_box(
						"You're already a quarter of the way there, so these should get you "
						+ "the rest of the way up.",
						320,
						166
					)
					var new_cards: Array[CardSpec] = [
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
						CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2)
					]
					core.get_node("HandMain").add_cards(new_cards)
				13:
					show_box("Have at it.", -1, -1, false)
					await_unlock = 1
				14:
					show_box(
						"Nice work.\n\n"
						+ "If you forget what any of the icons mean, you can hover over any of your picks "
						+ "and get a quick reminder. \n\n That applies to just about everything - so don't forget it!"
					)
				15:
					show_box("Let's reset that...", -1, -1, false)
					await reset_pins([PinSpec.from_depth_array()])
					advance()
				16:
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
					core.get_node("AnimationPlayer").play("show_deck_discard")
				17:
					highlight(core.get_node("DeckMain").get_nice_rect().grow(6))
					show_box(
						"This is your deck. This is where you keep all the picks you haven't used yet.\n\n"
						+ "You can the 'Deck' button to see all the cards currently in it.",
						64,
						272,
					)
				18:
					highlight(core.get_node("DeckMain/DeckLabel").get_global_rect().grow(6))
					await_display_close = 1
				19:
					show_box(
						"I've given you a couple of picks to get started.\n\n"
						+ "You'll be giving those back, so don't be too thankful."
					)
				20:
					show_box(
						"After you use a pick, if you have cards in your deck, you'll draw back "
						+ "up to three cards. Let's do that now."
					)
				21:
					core.draw_to_five()
					await core.animation_complete
					advance()
				22:
					var hand_rect: Rect2 = core.get_node("HandMain").get_global_rect()
					hand_rect = hand_rect.grow_individual(-128, 6, -126, 0)
					highlight(hand_rect)
					show_box(
						"This is your hand. We call it that, because these picks are in your hand, see? " 
						+ "All easy.\n\nYou can use any of the picks that are in your hand in any order.",
						256,
						200
					)
				23:
					highlight(core.get_node("DiscardMain/CardPile").get_global_rect().grow(6))
					show_box(
						"This is your discard pile. Picks you use end up here, hopefully",
						490,
						356,
					)
				24:
					show_box("Alright. Pick this lock again, and watch how your cards move.")
				25:
					await_unlock = 1
				26:
					show_box("Perfect. Two more things before I let you go for the day.")
				27:
					core.get_node("AnimationPlayer").play("show_trash")
					var t := create_tween()
					t.tween_interval(0.5)
					t.tween_callback(advance)
				28:
					highlight(core.get_node("TrashMain").get_global_rect().grow(6))
					show_box(
						"First: here's your trash pile. "
						+ "If you heck up and break picks, they end up here instead of in your discard.\n\n"
						+ "Broken picks are gone until you can repair them, which might be a bit and costs money.",
						440,
						280,
					)
				29:
					highlight(core.get_node("TrashMain").get_global_rect().grow(6))
					show_box(
						"Try real hard to avoid breaking picks. "
						+ "This is the skill that separates master thieves from rookies about to meet the bad end "
						+ "of a town guard.",
						440,
						280,
					)
				30:
					show_box(
						"With these training locks, there's really only one way to break a pick: "
						+ "push the pin past its final spot. Slamming a pin like that will break the pick.\n\n"
						+ "It's not all bad though, you'll still set the pin and can unlock the lock."
					)
				31:
					show_box(
						"Have a few more picks. Solve this lock by overshooting the pin and breaking a pick.\n\n"
						+ "Don't worry, these training picks are all cheap garbage anyway.",
						-1,
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
				32:
					if core.get_node("TrashMain").count() > 0:
						show_box("That pick is trashed! Now you know what not to do.")
					else:
						step = 30
						show_box(
							"Good work avoiding breaking the pick, but I need you to learn what "
							+ "it feels like. Try again, and make sure you don't accidentally unlock the lock "
							+ "without overshooting it this time."
						)
				33:
					show_box(
						"Alright, You're on your own for a bit. Pick this next lock without "
						+ "breaking a pick and I'll continue your training."
					)
				34:
					core.continue_to_next.emit()
					advance()
#				24:
#					show_box(
#					\n\n"
#						+ "Know that you can use every pick once per turn, after which your "
#						+ "discard pile gets shuffled back into your deck.\n\n
#					"Wrong! When picking real locks, you'll only get "
#						+ "to reload your deck twice before you run out of time.\n\n"
#						+ "The number of picks in your deck is your only resource, so make each one count."
#					)
#					core.get_node("AnimationPlayer").play("show_countdown")
#				25: 
#					highlight(
#						Rect2(Vector2(593, 174), Vector2(128, 280)).grow(6)
#					)
#					show_box(
#					"Each time you reload your deck, that's a 'turn'\n\n"
#						+ "You have to be fast. Pick the lock on your first turn - that is, without reloading once - "
#						+ "and you'll get a nice little bonus.\n\n"
#						+ "Reload once solve the lock on your second turn, that's okay.\n\n"
#						+ "Once you're on your third turn, you're out of time and you're going to "
#						+ "start breaking picks.", 
#						0, 
#						0
#					)

func advance(n := 1) -> void:
	step += n
	continuable = false
	do_step()

const DEFAULT_X := int((960 - 384) / 2.0)
const DEFAULT_Y := 128

const FX_SCRAPE := preload("res://assets/fx/card_scrape.ogg")

func show_box(
	text: String,
	origin_x: int = -1,
	origin_y: int = -1,
	continuable_ := true
):
	if origin_x == -1:
		origin_x = DEFAULT_X
	if origin_y == -1:
		origin_y = DEFAULT_Y
	
	GlobalEffects.request(FX_SCRAPE)
	%Label.text = text
	%TutorialBox.global_position = Vector2(origin_x, origin_y)
	%TutorialBox.visible = true
	%TutorialBox.size = Vector2.ZERO
	continuable = continuable_

func highlight(rect: Rect2) -> void:
	%HighlightRect.visible = true
	%HighlightRect.position = rect.position
	%HighlightRect.size = rect.size

const FX_CLICK := preload("res://assets/fx/shell_click.ogg")

func hide_all() -> void:
	%HighlightRect.visible = false
	%TutorialBox.visible = false
	%Arrows.visible = false
	GlobalEffects.request(FX_CLICK)

var continuable := false

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

var await_display_close := 0
func display_closed() -> void:
	if await_display_close:
		advance(await_display_close)
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

func _input(event: InputEvent) -> void:
	if (
		%TutorialBox.visible
		and event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and not event.pressed
	):
		hide_all()
		if continuable:
			advance()
