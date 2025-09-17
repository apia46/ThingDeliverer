extends InputOutput
class_name Inputter

static func getName() -> String: return "Input"

var itemDisplay:Items.Display

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	if !pathNode.nextNode: visualInstance = preload("res://scenes/entityVisuals/inputDirectionless.tscn").instantiate()
	else: visualInstance = preload("res://scenes/entityVisuals/input.tscn").instantiate();

	if pathNode.partialPath.getState() == PartialPath.STATES.COMPLETE and !itemDisplay: itemDisplay = scene.items.addDisplay(pathNode.partialPath.getItemType(), position, rotation)
	elif itemDisplay: itemDisplay = scene.items.removeDisplay(itemDisplay)
	super()

func updateNext() -> void:
	if pathNode.nextNode: pathNode.nextNode.entity.checkPrevious()
	else:
		var node = getNodeInputFromRelative(pathNode, Vector2i(0,-1))
		if node: node.entity.checkPrevious()

func asNodeOutputTo(node:PathNode) -> PathNode:
	if !pathNode.nextNode: return pathNode
	return pathNode if node.position == position + U.rotate(Vector2i(0,-1), rotation) else null

func checkNext() -> void:
	#if game.isDebug: scene.newDebugVisual(position, Color(1, 0, 0.4))
	if pathNode.nextNode and !pointing:
		rotation = U.v2itorot(pathNode.nextNode.position - position)
		pointing = true
		loadVisuals()
	if !pathNode.nextNode and pointing:
		pointing = false
		loadVisuals()
		for node in getSidesOf(pathNode):
			if node: node.entity.checkPrevious()

func hoverInfo(append:int=0) -> String:
	return super(2) \
	+ H.attribute("pair", H.specialName("{" + str(requestPair.id) + "}"), 2) \
	+ (H.attribute("facing", U.ROTATION_NAMES[rotation], 2) if pointing else "") \
	+ H.attribute("path", pathNode.partialPath.hoverInfo(), append, false)
