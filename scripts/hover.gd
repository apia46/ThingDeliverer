extends VBoxContainer
class_name H

const APPENDS = ["", " ", ","]

var previousErrors:Array[String] = []
var errors:Array[String] = ["sdfsdklf"]

@onready var main = get_node("main")
@onready var text = get_node("main/margins/text")

func setHover(entity:Entity):
	previousErrors = errors
	errors = []
	@warning_ignore("static_called_on_instance") text.text = opName("var", 1) + varName("hovered") + ":" + typeName(entity.getName()) + " = " + LBRACE + "\n" \
		+ entity.hoverInfo() \
	+ RBRACE
	var diff = len(errors) - len(previousErrors)
	if diff < 0:
		for i in -diff: remove_child(get_child(-1))
	if diff > 0:
		for i in diff: add_child(preload("res://scenes/hoverError.tscn").instantiate())
	for i in len(errors):
		get_child(i+1).get_node("text").text = errors[i]
	size = Vector2(0, 0)

const LBRACE:String = "[color=#FFD700]{[/color]"
const RBRACE:String = "[color=#FFD700]}[/color]"
const TAB:String = "	"

static func noneName(string:String, append:int=0) -> String: return string + APPENDS[append]
static func varName(string:String, append:int=0) -> String: return "[color=#9CDCFE]" + string + "[/color]" + APPENDS[append]
static func enumName(string:String, append:int=0) -> String: return "[color=#4FC1FF]" + string + "[/color]" + APPENDS[append]
static func typeName(string:String, append:int=0) -> String: return "[color=#ED61DF]" + string + "[/color]" + APPENDS[append]
static func opName(string:String, append:int=0) -> String: return "[color=#557BCC]" + string + "[/color]" + APPENDS[append]
static func specialName(string:String, append:int=0) -> String: return "[color=#D7BA7D]" + string + "[/color]" + APPENDS[append]

static func attribute(attrName:String, value:Variant, append:int=0, color:bool=true) -> String: return TAB + varName(attrName) + ": " + (enumName(str(value), append) if color else noneName(str(value), append)) + "\n"

static func debugAttribute(isDebug:bool, attrName:String, value:Variant, append:int=0, color:bool=true, prepend:String="") -> String: return TAB + prepend + specialName("@debug", 1) + varName(attrName) + ": " + (enumName(str(value), append) if color else noneName(str(value), append)) + "\n" if isDebug else ""

static func errorMessage(string:String) -> String: return "[color=#FF0066]ERROR[/color]: " + string
