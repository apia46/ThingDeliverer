extends InputOutput
class_name Outputter

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/output.tscn").instantiate()
	super()

func checkPrevious() -> void:
	var previousNode:PathNode = getNodeInputFromRelative(pathNode, Vector2i(0,-1))
	if previousNode:
		pathNode.previousNode = previousNode
		previousNode.nextNode = pathNode
		if previousNode.path and pathNode.isDirectlyAfter(previousNode):
			pathNode.joinAfter(previousNode)
			pathNode.path.complete()

func asNodeInputFrom(node:PathNode) -> PathNode: return pathNode if node.position != position + U.rotate(Vector2i(0,1), rotation) else null
