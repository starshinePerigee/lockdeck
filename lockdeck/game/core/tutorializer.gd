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
		],
		[
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
			CardSpec.from_template(PickTemplates.TUTORIAL_PUSH_2),
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
					await_use = true
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
					await_unlock = true
				14:
					show_box(
						"Nice work.\n\n"
						+ "If you forget what any of the icons mean, you can hover over any of your picks "
						+ "and get a quick reminder. \n\n That applies to just about everything - so don't forget it!"
					)
				15:
					show_box("Let's reset that...", -1, -1, false)
					core.get_node("LockBody/AnimationPlayer").play_backwards("unlock")
					var cylinders: Control = core.get_node(
						"LockBody/CylinderMain/Cylinders"
					)
					var new_pins: Array[PinSpec] = [PinSpec.from_depth_array()] 
					cylinders.animate_fall(new_pins)
					await core.animation_complete
					reset_pins([PinSpec.from_depth_array()])
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
					highlight(core.get_node("DeckMain").get_nice_rect())
					show_box(
						"This is your deck. This is where you keep all the picks you haven't used yet.\n\n"
						+ "You can the 'Deck' button to see all the cards currently in it.",
						64,
						272,
					)
				18:
					await_display_close = true
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
					pass
				
#											+ "By the way, we call the space all your active cards are in your 'hand'.\n\n"
#                    						+ "Because it's in your hand, see? All easy.",

func advance() -> void:
	step += 1
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

var await_use := false
func pick_used(_state: StateSpec) -> void:
	if await_use:
		await_use = false
		advance()

var await_unlock := false
func lock_unlocked() -> void:
	if await_unlock:
		await_unlock = false
		advance()

var await_display_close := false
func display_closed() -> void:
	if await_display_close:
		await_display_close = false
		advance()

func reset_pins(pins: Array[PinSpec]) -> void:
	core.get_node("LockBody/CylinderMain").load_new_lock(
		LockSpec.new(pins)
	)
	core.lock_complete = false

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
