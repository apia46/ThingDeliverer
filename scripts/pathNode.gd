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
	path = node.path
	index = node.index + 1
	previousNode = node
	node.nextNode = self
	entity.updateNext()

func disconnectFromPath() -> void:
	if !path: return
	if previousNode: previousNode.nextNode = null
	if path.completed: path.uncomplete()
	path = null
	entity.loadVisuals()
	if nextNode:
		nextNode.previousNode = null
		nextNode.entity.checkPrevious()

func isDirectlyAfter(candidatePrevious:PathNode) -> bool:
	return candidatePrevious and path and path == candidatePrevious.path and (index == candidatePrevious.index+1 or entity is Outputter)

func isBefore(candidateAfter:PathNode) -> bool:
	return candidateAfter and path and path == candidateAfter.path and index < candidateAfter.index

func isPathComplete() -> bool: return path and path.completed

func propagatePathCompleteness():
	entity.loadVisuals()
	if nextNode: nextNode.propagatePathCompleteness()
