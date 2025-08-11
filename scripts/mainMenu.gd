extends PanelContainer
class_name MainMenu

@onready var menu = get_node("/root/menu")

var cursorBlinkTimer:float = 0

func _ready() -> void:
	%lines.get_v_scroll_bar().visible = false
	%text.text = H.commentName("# Check the README.md for controls\n# Note that the game is currently quite unfinished") + "\n\n" + H.opName("var", 1) + H.varName("game") + " = " + H.typeName("ThingDeliverer") + "."
	setCursorPosition(Vector2i(26, 3))

func _process(delta: float) -> void:
	cursorBlinkTimer += delta
	%cursorRect.visible = cursorBlinkTimer >= 0.5
	if cursorBlinkTimer >= 1: cursorBlinkTimer -= 1

func setCursorPosition(pos:Vector2i):
	%cursor.position = pos * Vector2i(16, 35)

func autocompleted(_which:int) -> void:
	menu.startGame()