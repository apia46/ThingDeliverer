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
	if game.isDebug: scene.newDebugVisual(position, Color(0, 1, 0.4))
	var previousNode = getNodeInputFromRelative(pathNode, Vector2i(0,1))
	if previousNode: pathNode.partialJoinAfter(previousNode)

func updateNext() -> void:
	if pathNode.nextNode: pathNode.nextNode.entity.checkPrevious()

func asNodeInputFrom(node:PathNode) -> PathNode:
	return pathNode if node.position != position + U.rotate(Vector2i(0,-1), rotation) else null

func delete() -> void:
	super()
	game.undergroundsAvailable += 1
