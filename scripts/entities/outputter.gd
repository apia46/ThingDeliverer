extends InputOutput
class_name Outputter

static func getName() -> String: return "Output"

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	if !pathNode.previousNode: visualInstance = preload("res://scenes/entityVisuals/outputDirectionless.tscn").instantiate()
	else: visualInstance = preload("res://scenes/entityVisuals/output.tscn").instantiate()
	super()

func checkPrevious() -> void:
	var previousNode
	rotation = U.ROTATIONS.DOWN
	for direction in [Vector2i(0,1), Vector2i(0,-1), Vector2i(1,0), Vector2i(-1,0)]:
		previousNode = getNodeInputFromRelative(pathNode, direction)
		if previousNode:
			rotation = U.v2itorot(previousNode.position - position)
			break

	if previousNode:
		pathNode.partialJoinAfter(previousNode)
		if !pointing:
			rotation = U.v2itorot(previousNode.position - position)
			pointing = true
			loadVisuals()
	elif pointing:
			pointing = false
			rotation = U.ROTATIONS.UP
			if pathNode.previousNode:
				pathNode.previousNode.nextNode = null
				pathNode.previousNode = null
			loadVisuals()

func asNodeInputFrom(node:PathNode) -> PathNode:
	#print(pathNode.previousNode)
	if !pathNode.previousNode: return pathNode
	return pathNode if node.position != position + U.rotate(Vector2i(0,1), rotation) else null

func hoverInfo(append:int=0) -> String:
	return super(2) \
	+ H.attribute("pair", H.specialName("{" + str(requestPair.id) + "}"), 2) \
	+ (H.attribute("from", U.ROTATION_NAMES[rotation], 2) if pointing else "") \
	+ H.attribute("path", pathNode.partialPath.hoverInfo(), append, false)
