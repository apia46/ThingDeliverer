extends Underground
class_name UndergroundInput

static func getName() -> String: return "UnderpathInput"

func ready() -> void:
	pathNode = PathNode.new(self, position)
	super()

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
	if pathNode.nextNode: scene.deleteEntity(pathNode.nextNode.position)
	game.undergroundsAvailable += 1

func hoverInfo(append:int=0) -> String:
	return super(2) \
	+ H.debugAttribute(game.isDebug, "hasPrevious", !!pathNode.previousNode, 2) \
	+ H.debugAttribute(game.isDebug, "hasNext", !!pathNode.nextNode, 2) \
	+ H.attribute("facing", U.ROTATION_NAMES[rotation], 2) \
	+ H.attribute("path", pathNode.partialPath.hoverInfo(), append, false)
