extends Entity
class_name Throughpath

static func getName() -> String: return "Throughpath"

const NEAR_SIDE:Dictionary[Vector2i, Vector2i] = {
	Vector2i(0, 0): Vector2i(0, -1),
	Vector2i(-1, 0): Vector2i(-1, 0),
	Vector2i(-1, 1): Vector2i(0, 1),
	Vector2i(0, 1): Vector2i(1, 0)
}

var references:Array[ThroughpathReference] = []
var pathNode:PathNode
var itemDisplay:Items.Display
var isReady:bool = false # because it has to initialise the references, functions naming them directly need to be skipped within the readying
var isDeleted:bool = false # just to make sure it doesnt get told to delete itself again by the references

func ready() -> void:
	pathNode = PathNode.new(self, position)
	references.append(scene.placeEntity(ThroughpathReference, position + Vector2i(-1, 0), U.ROTATIONS.UP))
	references.append(scene.placeEntity(ThroughpathReference, position + Vector2i(-1, 1), U.ROTATIONS.UP))
	references.append(scene.placeEntity(ThroughpathReference, position + Vector2i(0, 1), U.ROTATIONS.UP))
	var idIter:int = 0
	for ref in references:
		ref.throughpath = self
		ref.subId = idIter
		idIter += 1
		ref.isReady = true
	isReady = true
	super()
	checkPrevious()
	updateNext()
	for ref in references:
		ref.checkPrevious()
		ref.updateNext()

func checkPrevious() -> void: checkPreviousOf(self.pathNode)
func updateNext() -> void: updateNextOf(self.pathNode)

func checkPreviousOf(node:PathNode) -> void:
	var previousNode = getNodeInputFromRelative(node, NEAR_SIDE[node.position - position])
	if !previousNode or previousNode.entity.getName() == "Throughpath": # easiest way to catch both throughpaths and throughpathreferences
		previousNode = getNodeInputFromRelative(node, NEAR_SIDE[node.position - position]*-2)
	if previousNode and previousNode.entity.getName() != "Throughpath": node.partialJoinAfter(previousNode)
	loadVisuals()

func updateNextOf(thisNode:PathNode) -> void:
	if thisNode.nextNode: thisNode.nextNode.entity.checkPrevious()
	elif thisNode.previousNode:
		var direction:Vector2i = thisNode.previousNode.position-thisNode.position
		var checkNode:PathNode
		if abs(direction.x) + abs(direction.y) == 2:
			checkNode = getNodeOutputFromRelative(thisNode,Vector2(direction)*-0.5)
			if game.isDebug: scene.newDebugVisual(Vector2(thisNode.position)+Vector2(direction)*-0.5, Color(0, 0.4, 1))
		else:
			checkNode = getNodeOutputFromRelative(thisNode,direction*-2)
			if game.isDebug: scene.newDebugVisual(Vector2(thisNode.position)+Vector2(direction)*-2, Color(0.6, 0.4, 1))
		if checkNode: checkNode.entity.checkPrevious()
	else:
		var checkNode:PathNode
		checkNode = getNodeOutputFromRelative(thisNode,NEAR_SIDE[thisNode.position-position])
		if game.isDebug: scene.newDebugVisual(thisNode.position+NEAR_SIDE[thisNode.position-position], Color(0, 0.4, 1))
		if !checkNode:
			if game.isDebug: scene.newDebugVisual(thisNode.position+NEAR_SIDE[thisNode.position-position]*-2, Color(0.6, 0.4, 1))
			checkNode = getNodeOutputFromRelative(thisNode,NEAR_SIDE[thisNode.position-position]*-2)
		if checkNode:
			checkNode.entity.checkPrevious()

func asNodeOutputTo(node:PathNode) -> PathNode: return asNodeInputFrom(node) # because its symmetrical
func asNodeInputFrom(node:PathNode) -> PathNode:
	if !isReady or isDeleted: return null
	if (node.position - position).x == 0: return pathNode
	elif (node.position - position).x == -1: return references[1].pathNode
	elif (node.position - position).y == 0: return references[0].pathNode
	elif (node.position - position).y == 1: return references[2].pathNode
	return null

func getSidesOf(node:PathNode) -> Array[PathNode]:
	var toReturn:Array[PathNode] = []
	for direction in [Vector2i(1, 0), Vector2i(1, 1)]:
		toReturn.append(getPathNodeRelative(U.rotate(direction, U.v2itorot(NEAR_SIDE[node.position-position]))))
	return toReturn

func delete() -> void:
	isDeleted = true
	pathNode.delete()
	if itemDisplay: scene.items.removeDisplay(itemDisplay)
	super()
	game.throughpathsAvailable += 1
	for ref in references:
		if !ref.isDeleted: scene.deleteEntity(ref.position)

func loadVisuals() -> void:
	if !visualInstance:
		visualInstance = preload("res://scenes/entityVisuals/throughpath.tscn").instantiate()
		super()
	if !isReady: return
	visualInstance.set_surface_override_material(1, references[0].pathNode.partialPath.getColorMaterial())
	visualInstance.set_surface_override_material(2, references[2].pathNode.partialPath.getColorMaterial())
	visualInstance.set_surface_override_material(3, pathNode.partialPath.getColorMaterial())
	visualInstance.set_surface_override_material(4, references[1].pathNode.partialPath.getColorMaterial())

	if pathNode.partialPath.getState() == PartialPath.STATES.COMPLETE:
		if !itemDisplay:
			var direction:Vector2i = pathNode.nextNode.position - pathNode.position
			if abs(direction.x) + abs(direction.y) == 2: itemDisplay = scene.items.addDisplay(pathNode.partialPath.getItemType(), position+Vector2i(Vector2(direction)*0.5), U.v2itorot(direction))
			else: itemDisplay = scene.items.addDisplay(pathNode.partialPath.getItemType(), position, U.v2itorot(direction))
	elif itemDisplay: itemDisplay = scene.items.removeDisplay(itemDisplay)

func hoverInfo(append:int=0) -> String:
	return super(2) \
	+ H.debugAttribute(game.isDebug, "hasPrevious", !!pathNode.previousNode, 2) \
	+ H.debugAttribute(game.isDebug, "hasNext", !!pathNode.nextNode, 2) \
	+ H.attribute("rightPath", pathNode.partialPath.hoverInfo(), append, false) \
