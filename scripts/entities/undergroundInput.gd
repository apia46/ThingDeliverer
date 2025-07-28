extends Underground
class_name UndergroundInput

func ready() -> void:
	pathNode = PathNode.new(self, position)
	super()
	findAndCheckPrevious()

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/undergroundInput.tscn").instantiate()
	super()

func findAndCheckPrevious() -> void:
	checkPrevious(getNodeInputFromRelative(pathNode, Vector2i(0,1)))

func checkPrevious(givenNode:PathNode) -> void:
	if givenNode:
		pathNode.previousNode = givenNode
		givenNode.nextNode = pathNode
		if !pathNode.path or !pathNode.isDirectlyAfter(givenNode): # no updates needed if so
			pathNode.joinAfter(givenNode)
		else: pathNode.disconnectFromPath()
	else: pathNode.disconnectFromPath()
	print("in ", pathNode.path)

func updateNext() -> void:
	if pathNode.nextNode: pathNode.nextNode.entity.checkPrevious(pathNode)

func asNodeInputFrom(node:PathNode) -> PathNode:
	return pathNode if node.position != position + U.rotate(Vector2i(0,-1), rotation) else null
