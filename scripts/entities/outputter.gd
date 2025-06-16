extends InputOutput
class_name Outputter

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/output.tscn").instantiate()
	super()

func checkPrevious() -> void:
	var previousNode:PathNode = getNodeInputFromRelative(Vector2i(0,-1))
	if previousNode:
		pathNode.previousNode = previousNode
		previousNode.nextNode = pathNode
		if previousNode.path and pathNode.isDirectlyAfter(previousNode):
			pathNode.joinAfter(previousNode)
			pathNode.path.complete()

func asNodeInputFrom(pos:Vector2i) -> PathNode: return pathNode if pos == position + U.rotate(Vector2i(0,-1), rotation) else null
