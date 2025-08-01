extends RefCounted
class_name PartialPath # called this because there used to be a Path that was Worse and only propagated from the input

var game:Game

var id:int
var itemType:Items.TYPES
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
