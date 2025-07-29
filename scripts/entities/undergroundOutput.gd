extends Underground
class_name UndergroundOutput

var itemDisplay:Items.Display

func ready() -> void:
	super()
	checkPrevious()
	updateNext()

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/undergroundOutput.tscn").instantiate()
	
	if pathNode.isPathComplete() and !itemDisplay: itemDisplay = scene.items.addDisplay(pathNode.path.itemType, position, U.r180(rotation))
	elif itemDisplay: itemDisplay = scene.items.removeDisplay(itemDisplay)
	super()

func checkPrevious() -> void:
	if game.isDebug: scene.newDebugVisual(position, Color(0, 1, 0.4))
	if !pathNode.previousNode:
		return delete()
	if pathNode.previousNode.path:
		if !pathNode.path:
			pathNode.joinAfter(pathNode.previousNode)
	else: pathNode.disconnectFromPath()
	# print("out ", pathNode.path)

func updateNext() -> void:
	if pathNode.nextNode: pathNode.nextNode.entity.checkPrevious()
	else:
		var node = getNodeOutputFromRelative(pathNode, Vector2i(0,1))
		if node: node.entity.checkPrevious()

func asNodeOutputTo(node:PathNode) -> PathNode: return pathNode if node.position == position + U.rotate(Vector2i(0,1), rotation) else null

func delete() -> void:
	if pathNode.previousNode: pathNode.previousNode.entity.delete()
	if itemDisplay: scene.items.removeDisplay(itemDisplay)
	super()
