extends RefCounted
class_name PartialPath # called this because there used to be a Path that was Worse and only propagated from the input

var game:Game

var id:int
var start:PathNode
var end:PathNode

enum STATES {INCOMPLETE, HAS_INPUT, HAS_OUTPUT, COMPLETE, ERROR}
const STATES_NAMES:Array[String] = ["INCOMPLETE", "HAS_INPUT", "HAS_OUTPUT", "COMPLETE", "ERROR"]
const STATES_COLORS:Array[BaseMaterial3D] = [
	null,
	preload("res://scenes/entityVisuals/materials/Blue.tres"),
	preload("res://scenes/entityVisuals/materials/Orange.tres"),
	preload("res://scenes/entityVisuals/materials/White.tres"),
	preload("res://scenes/entityVisuals/materials/Red.tres")
]

func _init(_game:Game, _start:PathNode) -> void:
	game = _game
	id = game.partialPathIdIncr
	game.partialPathIdIncr += 1
	start = _start
	end = start

func update() -> void:
	var head:PathNode = start
	head.entity.loadVisuals()

	if getState() == STATES.COMPLETE and !start.entity.requestPair.completed:
		start.entity.requestPair.completed = true
		game.pathComplete()
	if start.entity is Inputter and start.entity.requestPair.completed and getState() != STATES.COMPLETE:
		start.entity.requestPair.completed = false

	while head.nextNode:
		head = head.nextNode
		head.entity.loadVisuals()
		if head == end: return # in case of loops

func splitAt(pathNode:PathNode) -> void:
	var head:PathNode = pathNode
	if start.previousNode || pathNode.nextNode == start:
		# there is a loop
		start = pathNode.nextNode
		end = pathNode.previousNode
		update()
		return
	if head.nextNode:
		var forwards:PartialPath = PartialPath.new(game, head.nextNode)
		while head.nextNode:
			head = head.nextNode
			head.partialPath = forwards
		forwards.end = end
		forwards.update()
	end = pathNode.previousNode
	pathNode.partialPath.update()

func joinAfter(pathNode:PathNode) -> void:
	var toJoin = pathNode.partialPath
	if toJoin == self:
		# is a loop; could have left a broken lead if the loop was welded shut; regenerate from loop point
		update()
		toJoin = PartialPath.new(game, pathNode.nextNode)
		pathNode.nextNode.partialPath = toJoin
	var head:PathNode = pathNode.nextNode
	head.partialPath = toJoin
	while head.nextNode:
		head = head.nextNode
		head.partialPath = toJoin
		if head == pathNode.nextNode: break
	toJoin.end = head
	toJoin.update()

func getColorMaterial() -> BaseMaterial3D: return STATES_COLORS[getState()]

func mispairedError() -> Array[int]:
	if start.entity is Inputter and end.entity is Outputter and start.entity.requestPair != end.entity.requestPair:
		return [start.entity.requestPair.id, end.entity.requestPair.id]
	else: return []

func getState() -> STATES:
	if !start or !end: return STATES.INCOMPLETE # possible during deletion or whatever; shouldnt matter..?
	if mispairedError(): return STATES.ERROR
	return int(start.entity is Inputter) + int(end.entity is Outputter) * 2 as STATES

func getItemType() -> Items.TYPES:
	if mispairedError(): return Items.TYPES.NULL
	if start.entity is Inputter: return start.entity.requestPair.itemType
	if end.entity is Outputter: return end.entity.requestPair.itemType
	return Items.TYPES.NULL

func hoverInfo() -> String:
	var mispair = mispairedError()
	if mispair:
		game.hover.errors.append(H.errorMessage("tried to connect " + H.specialName("Input{%s}" % mispair[0]) + " to " + H.specialName("Output{%s}" % mispair[1])))
	return H.LBRACE + "\n" \
	+ H.debugAttribute(game.isDebug, "id", id, 2, true, H.TAB) \
	+ H.TAB + H.attribute("itemType", Items.TYPES_NAMES[getItemType()], 2) \
	+ H.TAB + H.attribute("state", STATES_NAMES[getState()]) \
	+ H.TAB + H.RBRACE
