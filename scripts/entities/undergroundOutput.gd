extends Underground
class_name UndergroundOutput

static func getName() -> String: return "UnderpathOutput"

var itemDisplay:Items.Display

func ready() -> void:
	super()
	updateNext()

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/undergroundOutput.tscn").instantiate()
	
	if pathNode.partialPath.getState() == PartialPath.STATES.COMPLETE and !itemDisplay: itemDisplay = scene.items.addDisplay(pathNode.partialPath.getItemType(), position, U.r180(rotation))
	elif itemDisplay: itemDisplay = scene.items.removeDisplay(itemDisplay)
	super()

func checkPrevious() -> void:
	#if game.isDebug: scene.newDebugVisual(position, Color(0, 1, 0.4))
	# print("out ", pathNode.path)
	pass

func updateNext() -> void:
	if pathNode.nextNode: pathNode.nextNode.entity.checkPrevious()
	else:
		var node = getNodeOutputFromRelative(pathNode, Vector2i(0,1))
		if node: node.entity.checkPrevious()

func asNodeOutputTo(node:PathNode) -> PathNode: return pathNode if node.position == position + U.rotate(Vector2i(0,1), rotation) else null

func delete() -> void:
	super()
	if pathNode.previousNode: scene.deleteEntity(pathNode.previousNode.position)
	if itemDisplay: scene.items.removeDisplay(itemDisplay)

func hoverInfo(append:int=0) -> String:
	return super(2) \
	+ H.debugAttribute(game.isDebug, "hasPrevious", !!pathNode.previousNode, 2) \
	+ H.debugAttribute(game.isDebug, "hasNext", !!pathNode.nextNode, 2) \
	+ H.attribute("facing", U.ROTATION_NAMES[U.rNeg(rotation)], 2) \
	+ H.attribute("path", pathNode.partialPath.hoverInfo(), append, false)

func getSidesOf(_pathNode:PathNode) -> Array[PathNode]:
	var toReturn:Array[PathNode] = []
	for direction in U.V2I_DIRECTIONS:
		if U.v2itorot(direction) != rotation:
			toReturn.append(getPathNodeRelative(direction))
	return toReturn
