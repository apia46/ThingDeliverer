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

func sides(_pathNode:PathNode) -> Array[Entity]:
	var toReturn:Array[Entity] = []
	if !pointing: toReturn.append(getEntityRelative(Vector2i(0, 1)))
	for direction in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0)]: toReturn.append(getEntityRelative(direction))
	return toReturn
