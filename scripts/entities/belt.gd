extends Entity
class_name Belt

const BELT_STRAIGHT:PackedScene = preload("res://scenes/entityVisuals/belt/Straight.tscn")
const BELT_CCW:PackedScene = preload("res://scenes/entityVisuals/belt/CCW.tscn")
const BELT_CW:PackedScene = preload("res://scenes/entityVisuals/belt/CW.tscn")

const CYAN:BaseMaterial3D = preload("res://scenes/entityVisuals/belt/Cyan.tres")
const WHITE:BaseMaterial3D = preload("res://scenes/entityVisuals/belt/White.tres")

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
	var previousNode
	previousDirection = U.ROTATIONS.DOWN
	for direction in [Vector2i(0,1), Vector2i(1,0), Vector2i(-1,0)]:
		previousNode = getNodeInputFromRelative(pathNode, direction)
		if previousNode:
			previousDirection = U.v2itorot(previousNode.position - position)
			break

	if previousNode:
		previousDirection = U.v2itorot(U.rotate(previousNode.position - position, U.rNeg(rotation)))

		if previousNode.path:
			if pathNode.path and pathNode.isBefore(previousNode): # path cuts itself off
				pathNode.disconnectFromPath()
			elif !pathNode.path or !pathNode.isDirectlyAfter(previousNode): # no updates needed if so
				pathNode.joinAfter(previousNode)
		else: pathNode.disconnectFromPath()
	else: pathNode.disconnectFromPath()
	
	loadVisuals()

func updateNext() -> void:
	if pathNode.nextNode: pathNode.nextNode.entity.checkPrevious()
	else:
		var node = getNodeOutputFromRelative(pathNode, Vector2i(0,-1))
		if node: node.entity.checkPrevious()

# direction changes
func loadVisuals() -> void:
	#print(str(!visualInstance) + str(currentlyDisplayedPreviousDirection) + str(previousDirection))
	var changingInstance:bool = !visualInstance or currentlyDisplayedPreviousDirection != previousDirection
	if changingInstance:
		if visualInstance: visualInstance.queue_free()
		match previousDirection:
			U.ROTATIONS.LEFT: visualInstance = BELT_CCW.instantiate()
			U.ROTATIONS.RIGHT: visualInstance = BELT_CW.instantiate()
			_: visualInstance = BELT_STRAIGHT.instantiate()
	
	if pathNode.path and pathNode.path.completed:
		#visualInstance.get_active_material(1).albedo_color = ACTIVATED_COLOR
		#visualInstance.get_active_material(1).emission = ACTIVATED_COLOR
		if !itemDisplay: itemDisplay = scene.items.addDisplay(pathNode.path.itemType, position, rotation)
	else:
		#visualInstance.get_active_material(1).albedo_color = DEACTIVATED_COLOR
		#visualInstance.get_active_material(1).emission = DEACTIVATED_COLOR
		if itemDisplay: itemDisplay = scene.items.removeDisplay(itemDisplay)
	
	if game.isDebug:
		visualInstance.get_node("debugText").visible = !!pathNode.partialPath
		if pathNode.path: visualInstance.get_node("debugText").text = str(pathNode.partialPath)
	
	if changingInstance: super()
	currentlyDisplayedPreviousDirection = previousDirection

	if pathNode.path:
		if pathNode.path.completed: visualInstance.set_surface_override_material(1, WHITE)
		else: visualInstance.set_surface_override_material(1, CYAN)
	else: visualInstance.set_surface_override_material(1, null)

func delete() -> void:
	pathNode.delete()
	if itemDisplay: scene.items.removeDisplay(itemDisplay)
	super()

func asNodeOutputTo(node:PathNode) -> PathNode: return pathNode if node.position == position + U.rotate(Vector2i(0,-1), rotation) else null
func asNodeInputFrom(node:PathNode) -> PathNode: return pathNode if node.position != position + U.rotate(Vector2i(0,-1), rotation) else null
