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

func disconnectFromPath(delete:=false) -> void:
	if nextNode:
		if delete:
			nextNode.previousNode = null
			nextNode.entity.previousWillBeDeleted()
		else:
			nextNode.entity.previousWillBeDisconnected()
	if previousNode:
		if delete: previousNode.nextNode = null
		previousNode.entity.checkNext()
	if path and path.completed: path.uncomplete()
	path = null
	entity.loadVisuals()

func isDirectlyAfter(candidatePrevious:PathNode) -> bool:
	return candidatePrevious and path and path == candidatePrevious.path and (index == candidatePrevious.index+1 or entity is Outputter)

func isBefore(candidateAfter:PathNode) -> bool:
	return candidateAfter and path and path == candidateAfter.path and index < candidateAfter.index

func isPathComplete() -> bool: return path and path.completed

func propagatePathCompleteness():
	entity.loadVisuals()
	if nextNode: nextNode.propagatePathCompleteness()
