extends Entity
class_name Belt

const BELT_STRAIGHT:PackedScene = preload("res://scenes/entityVisuals/beltStraight.tscn")
const BELT_CCW:PackedScene = preload("res://scenes/entityVisuals/beltCCW.tscn")
const BELT_CW:PackedScene = preload("res://scenes/entityVisuals/beltCW.tscn")

const DEACTIVATED_COLOR = Color(0x0D063AFF)
const ACTIVATED_COLOR = Color(0xFFD800FF)

var pathNode:PathNode

var currentlyDisplayedPreviousDirection:U.ROTATIONS
var previousDirection:U.ROTATIONS

var itemDisplay:Items.Display

func ready() -> void:
	pathNode = PathNode.new(self)
	super()
	checkPrevious()

func checkPrevious() -> void:
	var previousNode:PathNode = getNodeInputFromRelative(Vector2i(0,1))
	previousDirection = U.ROTATIONS.DOWN
	if !previousNode:
		previousNode = getNodeInputFromRelative(Vector2i(1,0))
		previousDirection = U.ROTATIONS.RIGHT
	if !previousNode:
		previousNode = getNodeInputFromRelative(Vector2i(-1,0))
		previousDirection = U.ROTATIONS.LEFT
	if !previousNode: previousDirection = U.ROTATIONS.DOWN
	
	if previousNode:
		if previousNode.path:
			if pathNode.path and pathNode.isBefore(previousNode): # path cuts itself off
				pathNode.disconnectFromPath()
			elif !pathNode.path or !pathNode.isDirectlyAfter(previousNode): # no updates needed if so
				pathNode.joinAfter(previousNode)
		else: pathNode.disconnectFromPath()
	else: pathNode.disconnectFromPath()
	
	loadVisuals()

func updateNext() -> void:
	var node = getNodeOutputFromRelative(Vector2i(0,-1))
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
		visualInstance.get_active_material(1).albedo_color = ACTIVATED_COLOR
		visualInstance.get_active_material(1).emission = ACTIVATED_COLOR
		if !itemDisplay: itemDisplay = scene.items.addDisplay(Items.TYPES.BOX, position, rotation)
	else:
		visualInstance.get_active_material(1).albedo_color = DEACTIVATED_COLOR
		visualInstance.get_active_material(1).emission = DEACTIVATED_COLOR
		if itemDisplay: itemDisplay = scene.items.removeDisplay(itemDisplay)
	
	if game.isDebug:
		visualInstance.get_node("debugText").visible = !!pathNode.path
		if pathNode.path: visualInstance.get_node("debugText").text = str(pathNode.path) + "-" + str(pathNode.index)
	
	if changingInstance: super()
	currentlyDisplayedPreviousDirection = previousDirection

func delete() -> void:
	pathNode.disconnectFromPath()
	if itemDisplay: scene.items.removeDisplay(itemDisplay)
	super()

func asNodeOutputTo(pos:Vector2i) -> PathNode: return pathNode if pos == position + U.rotate(Vector2i(0,-1), rotation) else null
func asNodeInputFrom(pos:Vector2i) -> PathNode: return pathNode # TODO:it doesnt really matter but like
