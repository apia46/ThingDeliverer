extends Entity
class_name InputOutput

var pathNode:PathNode
var pointing:bool = false
var requestPair:RequestPair

func ready() -> void:
	pathNode = PathNode.new(self, position)
	game.addRunningTimer(1, setHeight)
	super()

func setHeight(timeLeft) -> void:
	if !visualInstance: return
	visualInstance.position.y = max(0.5 - timeLeft*2.5, -1)

func loadVisuals() -> void:
	super()
	visualInstance.set_surface_override_material(1, pathNode.partialPath.getColorMaterial())

class RequestPair:
	var id:int
	var input:Inputter
	var output:Outputter
	var completed:bool = false
	var itemType:Items.TYPES

	func _init(_id:int, _itemType:Items.TYPES):
		id = _id
		itemType = _itemType
	
	func getPaths() -> Array[PartialPath]:
		var paths:Array[PartialPath] = []
		for entity in [input, output]:
			if entity and entity.pathNode.partialPath not in paths:
				paths.append(entity.pathNode.partialPath)
		return paths

class EntangledRequestPair:
	extends RequestPair

	var input2:Inputter
	var output2:Outputter
	var completed1:bool = false
	var completed2:bool = false
	var difference:Vector2i

	func getPaths() -> Array[PartialPath]:
		var paths:Array[PartialPath] = []
		for entity in [input, output, input2, output2]:
			if entity and entity.pathNode.partialPath not in paths:
				paths.append(entity.pathNode.partialPath)
		return paths

	func updateAll() -> void:
		for path in getPaths(): path.update()


func getSidesOf(_pathNode:PathNode) -> Array[PathNode]:
	var toReturn:Array[PathNode] = []
	if !pointing: toReturn.append(getPathNodeRelative(Vector2i(0, 1)))
	for direction in U.V2I_DIRECTIONS_NO_UP: toReturn.append(getPathNodeRelative(direction))
	return toReturn

func asPathNodeAt(_position:Vector2i) -> PathNode: return pathNode
