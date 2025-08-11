extends RefCounted
class_name PartialPath # called this because there used to be a Path that was Worse and only propagated from the input

var game:Game

var id:int
var start:PathNode
var end:PathNode

var typeError:String = ""

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
	var adjacentPaths:Array[PartialPath] = []
	while true:
		for side in head.entity.getSidesOf(head):
			if side and side.partialPath not in adjacentPaths: adjacentPaths.append(side.partialPath)
		if head.nextNode && head != end: head = head.nextNode
		else: break		# in case of loops

	typeError = ""
	if fridgeError(): typeError = H.specialName("TypeError") + ": item of type " + H.enumName("FRIDGE") + " cannot enter " + H.typeName("Underpaths")
	if magnetError(adjacentPaths): typeError = H.specialName("TypeError") + ": item of type " + H.enumName("MAGNET") + " cannot be adjacent to " + H.typeName("Metallic") + " items"
	if gyroError(): typeError = H.specialName("TypeError") + ": item of type " + H.enumName("GYRO") + " cannot turn counterclockwise"
	if chemicalError(): typeError = H.specialName("TypeError") + ": item of type " + H.enumName("CHEMICAL") + " cannot be exposed for\nlonger than ten consecutive tiles"
	if artifactError(): typeError = H.specialName("TypeError") + ": item of type " + H.enumName("ARTIFACT c") + "annot turn\n on odd " + H.typeName("parity[lb]//color] coordinates")
	if particleError(): typeError = H.specialName("TypeError") + ": item of type " + H.enumName("PARTICLE") + " must be entangled with its counterpart"

	if getItemType() != Items.TYPES.MAGNET:
		for path in adjacentPaths:
			if path.getItemType() == Items.TYPES.MAGNET: path.tryUpdate()
	
	if start.entity is Inputter and start.entity.requestPair.itemType == Items.TYPES.PARTICLE:
		var requestPair:InputOutput.RequestPair = start.entity.requestPair
		if getState() == STATES.COMPLETE and !requestPair.completed:
			if start.entity == requestPair.input: requestPair.completed1 = true
			else: requestPair.completed2 = true
			if requestPair.completed1 and requestPair.completed2:
				requestPair.completed = true
				game.pathComplete()
		if getState() != STATES.COMPLETE:
			if start.entity == requestPair.input: requestPair.completed1 = false
			else: requestPair.completed2 = false
			requestPair.completed = false
	else:
		if getState() == STATES.COMPLETE and !start.entity.requestPair.completed:
			start.entity.requestPair.completed = true
			game.pathComplete()
		if start.entity is Inputter and getState() != STATES.COMPLETE:
			start.entity.requestPair.completed = false
		
	head = start

	while true:
		head.entity.loadVisuals()
		if head.nextNode && head != end: head = head.nextNode
		else: break		# in case of loops
	
func splitAt(pathNode:PathNode) -> void:
	for side in pathNode.entity.getSidesOf(pathNode):
		if side and side.partialPath.getItemType() == Items.TYPES.MAGNET: side.partialPath.tryUpdate()
	var head:PathNode = pathNode
	if start.previousNode || pathNode.nextNode == start:
		# there is a loop
		start = pathNode.nextNode
		end = pathNode.previousNode
		tryUpdate()
		return
	if head.nextNode:
		var forwards:PartialPath = PartialPath.new(game, head.nextNode)
		while head.nextNode:
			head = head.nextNode
			head.partialPath = forwards
		forwards.end = end
		forwards.tryUpdate()
	end = pathNode.previousNode
	if end: end.nextNode = null # hghghghhhh
	tryUpdate()

func joinAfter(pathNode:PathNode) -> void:
	var toJoin = pathNode.partialPath
	if toJoin == self:
		# is a loop; could have left a broken lead if the loop was welded shut; regenerate from loop point
		tryUpdate()
		toJoin = PartialPath.new(game, pathNode.nextNode)
		pathNode.nextNode.partialPath = toJoin
	var head:PathNode = pathNode.nextNode
	head.partialPath = toJoin
	while head.nextNode:
		head = head.nextNode
		head.partialPath = toJoin
		if head == pathNode.nextNode: break
	toJoin.end = head
	toJoin.tryUpdate()

func getColorMaterial() -> BaseMaterial3D: return STATES_COLORS[getState()]

func mispairedError() -> Array[int]:
	if start.entity is Inputter and end.entity is Outputter and start.entity.requestPair != end.entity.requestPair:
		return [start.entity.requestPair.id, end.entity.requestPair.id]
	else: return []

func getState() -> STATES:
	if !start or !end: return STATES.INCOMPLETE # possible during deletion or whatever; shouldnt matter..?
	if mispairedError(): return STATES.ERROR
	if typeError: return STATES.ERROR
	return int(start.entity is Inputter) + int(end.entity is Outputter) * 2 as STATES

func getItemType() -> Items.TYPES:
	if !start or !end: return Items.TYPES.NULL
	if mispairedError(): return Items.TYPES.NULL
	if start.entity is Inputter: return start.entity.requestPair.itemType
	if end.entity is Outputter: return end.entity.requestPair.itemType
	return Items.TYPES.NULL

func hoverInfo() -> String:
	var mispair = mispairedError()
	if mispair:
		game.hover.errors.append(H.errorMessage(H.specialName("PointerError") + ": cannot connect " + H.specialName("Input{%s}" % mispair[0]) + " to " + H.specialName("Output{%s}" % mispair[1])))
	if typeError:
		game.hover.errors.append(H.errorMessage(typeError))
	@warning_ignore("static_called_on_instance") return H.LBRACE + "\n" \
	+ H.debugAttribute(game.isDebug, "id", id, 2, true, H.TAB) \
	+ H.debugAttribute(game.isDebug, "start", start.entity.getName() if start.entity else "n/a", 2, true, H.TAB) \
	+ H.debugAttribute(game.isDebug, "end", end.entity.getName() if end.entity else "n/a", 2, true, H.TAB) \
	+ H.TAB + H.attribute("itemType", Items.TYPES_NAMES[getItemType()], 2) \
	+ H.TAB + H.attribute("state", STATES_NAMES[getState()]) \
	+ H.TAB + H.RBRACE

func tryUpdate() -> void:
	if getItemType() == Items.TYPES.PARTICLE:
		getRequestPair().updateAll()
	else:
		update()

func getRequestPair() -> InputOutput.RequestPair:
	if start.entity is Inputter: return start.entity.requestPair
	if end.entity is Outputter: return end.entity.requestPair
	return null

# type checks
func fridgeError() -> bool:
	if getItemType() != Items.TYPES.FRIDGE: return false
	var head:PathNode = start
	while true:
		if head.entity is UndergroundInput: return true
		if head.nextNode: head = head.nextNode
		else: break
	return false

func magnetError(adjacentPaths:Array[PartialPath]) -> bool:
	if getItemType() != Items.TYPES.MAGNET: return false
	for path in adjacentPaths:
		if Items.isMetallic(path.getItemType()): return true
	return false

func gyroError() -> bool:
	if getItemType() != Items.TYPES.GYRO: return false
	var head:PathNode = start
	while true:
		if head.entity is Belt and head.entity.previousDirection == U.ROTATIONS.LEFT: return true
		if head.nextNode: head = head.nextNode
		else: break
	return false

func chemicalError() -> bool:
	if getItemType() != Items.TYPES.CHEMICAL: return false
	var head:PathNode = start
	var count:int = 0
	while true:
		if head.entity is Belt:
			count += 1
			if count > 10: return true
		else: count = 0
		if head.nextNode: head = head.nextNode
		else: break
	return false

func artifactError() -> bool:
	if getItemType() != Items.TYPES.ARTIFACT: return false
	var head:PathNode = start
	while true:
		if head.entity is Belt and head.entity.previousDirection != U.ROTATIONS.DOWN and head.position % 2 != Vector2i(0,0): return true
		if head.nextNode: head = head.nextNode
		else: break
	return false

func particleError() -> bool:
	if getItemType() != Items.TYPES.PARTICLE: return false
	var requestPair:InputOutput.EntangledRequestPair
	if start.entity is Inputter:
		requestPair = start.entity.requestPair
		var head1:PathNode = requestPair.input.pathNode
		var head2:PathNode = requestPair.input2.pathNode
		while true:
			if head1.nextNode and head2.nextNode:
				if head1.nextNode.position - head1.position != head2.nextNode.position - head2.position: return true
				# i know this isnt everything that needs to be checked but i cant be bothered. go exploit this really inefficiently by desyncing from redirection or whatever
				head1 = head1.nextNode
				head2 = head2.nextNode
			elif head1.nextNode or head2.nextNode: return true
			else: break
	else:
		requestPair = end.entity.requestPair
		var tail1:PathNode = requestPair.output.pathNode
		var tail2:PathNode = requestPair.output2.pathNode
		while true:
			if tail1.previousNode and tail2.previousNode:
				if tail1.previousNode.position - tail1.position != tail2.previousNode.position - tail2.position: return true
				tail1 = tail1.previousNode
				tail2 = tail2.previousNode
			elif tail1.previousNode or tail2.previousNode: return true
			else: break
	return false
