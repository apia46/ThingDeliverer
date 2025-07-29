extends RefCounted
class_name PathNode

var path:Path
var index:int
var entity:Entity

var position:Vector2i

var previousNode:PathNode
var nextNode:PathNode

func _init(_entity:Entity, _position:Vector2i):
	entity = _entity
	position = _position

func joinAfter(node:PathNode) -> void:
	if isDirectlyAfter(node): return
	if path: disconnectFromPath()
	path = node.path
	index = node.index + 1
	previousNode = node
	node.nextNode = self
	entity.updateNext()
	node.entity.joinedBefore(self)

func delete() -> void:
	if path and path.completed: path.uncomplete()
	if nextNode: nextNode.previousNode = null # is this necessary?
	entity.updateNext()
	if previousNode:
		previousNode.nextNode = null
		previousNode.entity.checkNext()

func disconnectFromPath() -> void:
	if !path: return
	if path.completed: path.uncomplete()
	path = null
	if previousNode:
		previousNode.nextNode = null
		previousNode.entity.checkNext()
	entity.updateNext()
	entity.loadVisuals()

func isDirectlyAfter(candidatePrevious:PathNode) -> bool:
	return candidatePrevious and path and path == candidatePrevious.path and (index == candidatePrevious.index+1 or entity is Outputter)

func isBefore(candidateAfter:PathNode) -> bool:
	return candidateAfter and path and path == candidateAfter.path and index < candidateAfter.index

func isPathComplete() -> bool: return path and path.completed

func propagatePathCompleteness():
	entity.loadVisuals()
	if nextNode: nextNode.propagatePathCompleteness()
