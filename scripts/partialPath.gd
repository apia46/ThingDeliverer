extends RefCounted
class_name PartialPath # called this because there used to be a Path that was Worse and only propagated from the input

var game:Game

var id:int
var start:PathNode
var end:PathNode

func _init(_game:Game, _start:PathNode) -> void:
	game = _game
	id = game.partialPathIdIncr
	game.partialPathIdIncr += 1
	start = _start
	end = start

func update() -> void:
	var head:PathNode = start
	head.entity.loadVisuals()

	if isComplete() and !start.entity.requestPair.completed:
		start.entity.requestPair.completed = true
		game.pathComplete()
	if start.entity is Inputter and start.entity.requestPair.completed and !isComplete():
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

func isComplete() -> bool: return start.entity is Inputter and end.entity is Outputter and start.entity.requestPair == end.entity.requestPair

func isConnectedButWrong() -> bool: return start.entity is Inputter and end.entity is Outputter and start.entity.requestPair != end.entity.requestPair

func getColorMaterial() -> BaseMaterial3D:
	if !start or !end: return null # possible during deletion or whatever; shouldnt matter..?
	if isConnectedButWrong(): return preload("res://scenes/entityVisuals/materials/Red.tres")
	return [
		null,
		preload("res://scenes/entityVisuals/materials/Blue.tres"),
		preload("res://scenes/entityVisuals/materials/Orange.tres"),
		preload("res://scenes/entityVisuals/materials/White.tres"),
	][int(start.entity is Inputter) + int(end.entity is Outputter) * 2]

func getItemType() -> Items.TYPES:
	if isConnectedButWrong(): return Items.TYPES.NULL
	if start.entity is Inputter: return start.entity.requestPair.itemType
	if end.entity is Outputter: return end.entity.requestPair.itemType
	return Items.TYPES.NULL
