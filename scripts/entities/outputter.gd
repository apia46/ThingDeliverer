extends InputOutput
class_name Outputter

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	if !pathNode.previousNode: visualInstance = preload("res://scenes/entityVisuals/outputDirectionless.tscn").instantiate()
	else: visualInstance = preload("res://scenes/entityVisuals/output.tscn").instantiate()
	super()

func checkPrevious(givenNode:PathNode) -> void:
	if givenNode:
		pathNode.previousNode = givenNode
		givenNode.nextNode = pathNode
		if givenNode.path and pathNode.isDirectlyAfter(givenNode):
			pathNode.joinAfter(givenNode)
			pathNode.path.complete()
			rotation = U.v2itorot(givenNode.position - position)
			pointing = true
			super(givenNode)
			loadVisuals()
	elif pointing:
		pointing = false
		rotation = U.ROTATIONS.UP
		if pathNode.previousNode:
			pathNode.previousNode.nextNode = null
			pathNode.previousNode = null
		loadVisuals()

func asNodeInputFrom(node:PathNode) -> PathNode:
	print(pathNode.previousNode)
	if !pathNode.previousNode: return pathNode
	return pathNode if node.position != position + U.rotate(Vector2i(0,1), rotation) else null
