extends Entity
class_name Belt

const BELT_STRAIGHT:PackedScene = preload("res://scenes/entityVisuals/belt/Straight.tscn")
const BELT_CCW:PackedScene = preload("res://scenes/entityVisuals/belt/CCW.tscn")
const BELT_CW:PackedScene = preload("res://scenes/entityVisuals/belt/CW.tscn")


var pathNode:PathNode

var currentlyDisplayedPreviousDirection:U.ROTATIONS
var previousDirection:U.ROTATIONS

var itemDisplay:Items.Display

func ready() -> void:
	pathNode = PathNode.new(self, position)
	super()
	checkPrevious()
	updateNext()

func checkPrevious() -> void:
	if game.isDebug: scene.newDebugVisual(position, Color(0, 1, 0.4))
	var previousNode:PathNode
	previousDirection = U.ROTATIONS.DOWN
	for direction in [Vector2i(0,1), Vector2i(1,0), Vector2i(-1,0)]:
		previousNode = getNodeInputFromRelative(pathNode, direction)
		if previousNode:
			previousDirection = U.v2itorot(previousNode.position - position)
			break

	if previousNode:
		previousDirection = U.v2itorot(U.rotate(previousNode.position - position, U.rNeg(rotation)))
		pathNode.partialJoinAfter(previousNode)
	
	loadVisuals()

func updateNext() -> void:
	if pathNode.nextNode: pathNode.nextNode.entity.checkPrevious()
	else:
		var node = getNodeOutputFromRelative(pathNode, Vector2i(0,-1))
		if node: node.entity.checkPrevious()

# direction changes
func loadVisuals() -> void:
	#print(str(!visualInstance) + str(currentlyDisplayedPreviousDirection) + str(previousDirection))
	assert(!deleted)

	var changingInstance:bool = !visualInstance or currentlyDisplayedPreviousDirection != previousDirection
	if changingInstance:
		if visualInstance: visualInstance.queue_free()
		match previousDirection:
			U.ROTATIONS.LEFT: visualInstance = BELT_CCW.instantiate()
			U.ROTATIONS.RIGHT: visualInstance = BELT_CW.instantiate()
			_: visualInstance = BELT_STRAIGHT.instantiate()
	
	if pathNode.partialPath.isComplete(): if !itemDisplay: itemDisplay = scene.items.addDisplay(pathNode.partialPath.getItemType(), position, rotation)
	else: if itemDisplay: itemDisplay = scene.items.removeDisplay(itemDisplay)
	
	if game.isDebug:
		visualInstance.get_node("debugText").visible = true
		#visualInstance.get_node("debugText").text = str(pathNode.partialPath.id) + U.boolToText(pathNode == pathNode.partialPath.start) + U.boolToText(pathNode == pathNode.partialPath.end) + U.boolToText(pathNode.previousNode) + U.boolToText(pathNode.nextNode)
		visualInstance.get_node("debugText").text = U.boolToText(pathNode.partialPath.isComplete())
	
	if changingInstance: super()
	currentlyDisplayedPreviousDirection = previousDirection

	visualInstance.set_surface_override_material(1, pathNode.partialPath.getColorMaterial())


func delete() -> void:
	pathNode.delete()
	if itemDisplay: scene.items.removeDisplay(itemDisplay)
	super()

func asNodeOutputTo(node:PathNode) -> PathNode: return pathNode if node.position == position + U.rotate(Vector2i(0,-1), rotation) else null
func asNodeInputFrom(node:PathNode) -> PathNode: return pathNode if node.position != position + U.rotate(Vector2i(0,-1), rotation) else null
