extends PanelContainer
class_name MainMenu

const METHOD_ICON:CompressedTexture2D = preload("res://resources/ui/cube.png")
const ENUM_ICON:CompressedTexture2D = preload("res://resources/ui/enum.png")
const PLAY_ICON:CompressedTexture2D = preload("res://resources/ui/play.png")

var DIALOGUE:Array[String] = [
	H.commentName(
"# ThingDeliverer v0.1.0
# Check the README.md for information") + "\n\n" + H.opName("var", 1) + H.varName("game") + " = " + H.typeName("ThingDeliverer") + ".",
	H.funcName("new") + H.LPAR + "\n" + H.TAB + "\n" + H.TAB + "\n" + H.RPAR + "\n",
	H.typeName("Timer") + "." + H.enumName("NORMAL", 2),
	H.typeName("Timer") + "." + H.enumName("INFINITE", 2),
	H.typeName("Difficulty") + "." + H.enumName("NORMAL"),
	H.typeName("Difficulty") + "." + H.enumName("HARD"),
]

@onready var menu:Menu = get_node("/root/menu")

var cursorBlinkTimer:float = 0
var dialogueTimer:float = 0

var dialogueToRead:int = -1
var dialogueIndex:int = 0
var cursorPosition:Vector2i = Vector2i(0, 0)

var whichAutocomplete:int = -1

var offsetEnd:int = 0

var timerExists:bool
var hardMode:bool

func _ready() -> void:
	%lines.get_v_scroll_bar().visible = false

func loadDialogue(which:int) -> void:
	if which == 0:
		offsetEnd = 0
		%text.text = ""
		cursorPosition = Vector2i(0, 0)
		%cursor.position = Vector2(0, 0)
	dialogueToRead = which
	dialogueIndex = 0
	%autocomplete.visible = false

func _process(delta:float) -> void:
	cursorBlinkTimer += delta
	%cursorRect.visible = cursorBlinkTimer < 0.5
	if cursorBlinkTimer >= 1: cursorBlinkTimer -= 1
	if dialogueToRead != -1:
		dialogueTimer += delta
		while dialogueTimer > 0:
			dialogueTimer -= 0.005
			cursorBlinkTimer = 0
			while DIALOGUE[dialogueToRead][dialogueIndex] == "[":
				while true:
					type()
					dialogueIndex += 1
					if dialogueIndex >= len(DIALOGUE[dialogueToRead]): break
					if DIALOGUE[dialogueToRead][dialogueIndex-1] == "]": break
				if dialogueIndex >= len(DIALOGUE[dialogueToRead]): break
			if dialogueIndex >= len(DIALOGUE[dialogueToRead]):
				loadAutocomplete(dialogueToRead)
				dialogueToRead = -1
				break
			type()
			if DIALOGUE[dialogueToRead][dialogueIndex] == "\n":
				cursorPosition = Vector2i(0, cursorPosition.y+1)
				%cursor.position = cursorPosition * Vector2i(0, 35)
			else: cursorPosition.x += 1
			dialogueIndex += 1
			if dialogueIndex >= len(DIALOGUE[dialogueToRead]):
				loadAutocomplete(dialogueToRead)
				dialogueToRead = -1
				break
	%cursor.position.x += (cursorPosition.x*16 - %cursor.position.x) * 0.25

func _input(event:InputEvent) -> void:
	if whichAutocomplete != -1 and event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_TAB:
				autocompleted(0)

func loadAutocomplete(which:int) -> void:
	whichAutocomplete = which
	%autocomplete.visible = true
	for button in %autocompleteCont.get_children(): button.visible = false
	match which:
		0:
			showAutocompleteButton(0, "new()", METHOD_ICON)
		1:
			cursorPosition = Vector2i(4, cursorPosition.y-3)
			%cursor.position = cursorPosition * Vector2i(0, 35)
			offsetEnd += 28
			showAutocompleteButton(0, "Timer.NORMAL")
			showAutocompleteButton(1, "Timer.INFINITE")
		2, 3:
			whichAutocomplete = 3
			cursorPosition = Vector2i(4, cursorPosition.y+1)
			%cursor.position = cursorPosition * Vector2i(0, 35)
			offsetEnd -= 2
			showAutocompleteButton(0, "Difficulty.NORMAL")
			showAutocompleteButton(1, "Difficulty.HARD")
		4, 5:
			whichAutocomplete = 5
			cursorPosition = Vector2i(0, cursorPosition.y+2)
			%cursor.position = cursorPosition * Vector2i(0, 35)
			offsetEnd = 0
			showAutocompleteButton(0, 'Run "game.gd"', PLAY_ICON)

func showAutocompleteButton(which:int, text:String, icon:CompressedTexture2D=ENUM_ICON) -> void:
	%autocompleteCont.get_child(which).visible = true
	%autocompleteCont.get_child(which).text = text
	%autocompleteCont.get_child(which).icon = icon

func type() -> void:
	%text.text = %text.text.insert(len(%text.text) - offsetEnd, DIALOGUE[dialogueToRead][dialogueIndex])

func autocompleted(which:int) -> void:
	match whichAutocomplete:
		1: timerExists = !which
		3: hardMode = !!which
		5:
			whichAutocomplete = -1
			return menu.startGame(timerExists, hardMode)
	loadDialogue(whichAutocomplete + which + 1)
	whichAutocomplete = -1
