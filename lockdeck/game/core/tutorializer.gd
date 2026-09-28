extends Control
## Tutorializer is a scene used to display tutorial info such as a popup and hint arrows.
## It also manages demo logic, working with game manager and game spec to step through tutorials.
class_name Tutorializer

# Tutorial logic:
# on tutorial start, we enter the tutorial state and create a game that's in the tutorial mode.
# game spec's tutorial level array manages TUTORIAL levelspecs and SPECIFIC levelspecs

# These static vars are pulled into gamespec but this class also serves as a sort of hub for logic

static var TUTORIAL_1 := StateSpec.new(
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
	LevelSpec.new(TUTORIAL, 1, 0, TUTORIAL_1),
	LevelSpec.new(SPECIFIC, 0, 0, CHALLENGE_1),
	LevelSpec.new(TUTORIAL, 2, 0, TUTORIAL_1),
]

func tutorialize(level: int) -> void:
	match level:
		1:
			show_box("Tutorial 1", Vector2(100, 100))
		2:
			show_box("Tutorial 2", Vector2(200, 200))
			highlight(Rect2(Vector2(150, 150), Vector2(356, 300)))
			closable = true
			

func show_box(text: String, pos: Vector2):
	%Label.text = text
	%TutorialBox.position = pos
	%TutorialBox.visible = true

func highlight(rect: Rect2) -> void:
	%HighlightRect.visible = true
	%HighlightRect.position = rect.position
	%HighlightRect.size = rect.size

func hide_all() -> void:
	%HighlightRect.visible = false
	%TutorialBox.visible = false
	%Arrows.visible = false

var closable := false:
	set(v):
		closable = v
		%CloseLabel.visible = closable

func _input(event: InputEvent) -> void:
	if (
		closable
		and event is InputEventMouseButton
		and not event.pressed
	):
		closable = false
		hide_all()
