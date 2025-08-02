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
	if game.isDebug: scene.newDebugVisual(position, Color(0, 1, 0.4))
	if !pathNode.previousNode:
		return delete()
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
