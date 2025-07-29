extends Underground
class_name UndergroundInput

func ready() -> void:
	pathNode = PathNode.new(self, position)
	super()
	checkPrevious()

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/undergroundInput.tscn").instantiate()
	super()

func checkPrevious() -> void:
	var previousNode = getNodeInputFromRelative(pathNode, Vector2i(0,1))
	if previousNode:
		pathNode.previousNode = previousNode
		previousNode.nextNode = pathNode
		if !pathNode.path or !pathNode.isDirectlyAfter(previousNode): # no updates needed if so
			pathNode.joinAfter(previousNode)
		else: pathNode.disconnectFromPath()
	else: pathNode.disconnectFromPath()
	#print("in ", pathNode.path)

func updateNext() -> void:
	if pathNode.nextNode: pathNode.nextNode.entity.checkPrevious()

func asNodeInputFrom(node:PathNode) -> PathNode:
	return pathNode if node.position != position + U.rotate(Vector2i(0,-1), rotation) else null
