extends Entity
class_name Throughpath

const NEAR_SIDE:Dictionary[Vector2i, Vector2i] = {
	Vector2i(0, 0): Vector2i(0, -1),
	Vector2i(-1, 0): Vector2i(-1, 0),
	Vector2i(-1, 1): Vector2i(0, 1),
	Vector2i(0, 1): Vector2i(1, 0)
}

var references:Array[ThroughpathReference] = []
var pathNode:PathNode

func ready() -> void:
	pathNode = PathNode.new(self, position)
	references.append(scene.placeEntity(ThroughpathReference, position + Vector2i(-1, 0), U.ROTATIONS.UP))
	references.append(scene.placeEntity(ThroughpathReference, position + Vector2i(-1, 1), U.ROTATIONS.UP))
	references.append(scene.placeEntity(ThroughpathReference, position + Vector2i(0, 1), U.ROTATIONS.UP))
	for ref in references:
		ref.throughpath = self
	super()
	checkPrevious()
	updateNext()

func checkPrevious() -> void: checkPreviousOf(self.pathNode)
func updateNext() -> void: updateNextOf(self.pathNode)

func checkPreviousOf(node:PathNode) -> void:
	if game.isDebug: scene.newDebugVisual(position, Color(0, 1, 0.4))
	var previousNode = getNodeInputFromRelative(node, NEAR_SIDE[node.position - position])
	if !previousNode:
		previousNode = getNodeInputFromRelative(node, NEAR_SIDE[node.position - position]*-2)
	if previousNode: node.partialJoinAfter(previousNode)
	if game.isDebug and previousNode: scene.newDebugVisual(position+Vector2i(0, -1), Color(0, 1, 0.4))
	loadVisuals()

func updateNextOf(node:PathNode) -> void:
	pass

func asNodeOutputTo(node:PathNode) -> PathNode: return asNodeInputFrom(node)
func asNodeInputFrom(node:PathNode) -> PathNode:
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
	super()
	for ref in references:
		scene.deleteEntity(ref.position)

func loadVisuals() -> void:
	if !visualInstance:
		visualInstance = preload("res://scenes/entityVisuals/throughpath.tscn").instantiate()
		super()
	
	visualInstance.set_surface_override_material(1, references[0].pathNode.partialPath.getColorMaterial())
	visualInstance.set_surface_override_material(2, references[2].pathNode.partialPath.getColorMaterial())
	visualInstance.set_surface_override_material(3, pathNode.partialPath.getColorMaterial())
	visualInstance.set_surface_override_material(4, references[1].pathNode.partialPath.getColorMaterial())
