extends RefCounted
class_name PathNode

var partialPath:PartialPath
var index:int
var entity:Entity

var position:Vector2i

var previousNode:PathNode
var nextNode:PathNode

func _init(_entity:Entity, _position:Vector2i):
	entity = _entity
	position = _position
	partialPath = PartialPath.new(entity.game, self)

func partialJoinAfter(node:PathNode) -> void:
	if previousNode == node: return
	if previousNode:
		previousNode.nextNode = null
		previousNode.partialPath.end = previousNode
		previousNode.partialPath.tryUpdate()
	previousNode = node
	node.nextNode = self
	partialPath.joinAfter(node)
	previousNode.entity.checkNext()

func delete() -> void:
	if nextNode: nextNode.previousNode = null # is this necessary?
	partialPath.splitAt(self)
	if entity is Throughpath:
		entity.updateNext()
	else:
		entity.updateNext()
	if previousNode:
		previousNode.nextNode = null # cant before updatenext because of loop detection in partialpath. fucked up i know
		previousNode.entity.checkNext()
