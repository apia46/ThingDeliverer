extends Entity
class_name ThroughpathReference

static func getName() -> String: return "Throughpath"

var throughpath:Throughpath
var pathNode:PathNode
var itemDisplay:Items.Display
var subId:int
var isReady:bool = false # because it doesnt get access to the throughpath before the throughpath's ready is called, things that refer to it need to be skipped within readying
var isDeleted:bool = false # so that it doesnt get deleted again by throughpath

func ready() -> void:
	pathNode = PathNode.new(self, position)
	super()

func loadVisuals() -> void:
	if !isReady: return
	throughpath.loadVisuals()

	if pathNode.partialPath.getState() == PartialPath.STATES.COMPLETE:
		if !itemDisplay:
			var direction:Vector2i = pathNode.nextNode.position - pathNode.position
			if abs(direction.x) + abs(direction.y) == 2: itemDisplay = scene.items.addDisplay(pathNode.partialPath.getItemType(), position+Vector2i(Vector2(direction)*0.5), U.v2itorot(direction))
			else: itemDisplay = scene.items.addDisplay(pathNode.partialPath.getItemType(), position, U.v2itorot(direction))
	elif itemDisplay: itemDisplay = scene.items.removeDisplay(itemDisplay)

func delete() -> void:
	isDeleted = true
	if !throughpath.deleted:
		scene.deleteEntity(throughpath.position)
	pathNode.delete()
	if itemDisplay: scene.items.removeDisplay(itemDisplay)
	super()

func asNodeOutputTo(node:PathNode) -> PathNode: return throughpath.asNodeOutputTo(node) if isReady else null
func asNodeInputFrom(node:PathNode) -> PathNode: return throughpath.asNodeInputFrom(node) if isReady else null
func asPathNodeAt(_position:Vector2i) -> PathNode: return pathNode

func checkPrevious() -> void: if isReady: throughpath.checkPreviousOf(pathNode)
func updateNext() -> void: if isReady: throughpath.updateNextOf(pathNode)

func getSidesOf(node:PathNode) -> Array[PathNode]: return throughpath.getSidesOf(node) if isReady else []

func hoverInfo(append:int=0) -> String:
	return super(2) \
	+ H.debugAttribute(game.isDebug, "hasPrevious", !!pathNode.previousNode, 2) \
	+ H.debugAttribute(game.isDebug, "hasNext", !!pathNode.nextNode, 2) \
	+ H.attribute(["upperPath", "leftPath", "lowerPath"][subId], pathNode.partialPath.hoverInfo(), append, false) \
