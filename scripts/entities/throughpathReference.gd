extends Entity
class_name ThroughpathReference

var throughpath:Throughpath
var pathNode:PathNode

func ready() -> void:
	pathNode = PathNode.new(self, position)
	super()

func loadVisuals() -> void:
	if game.isDebug:
		if visualInstance: visualInstance.queue_free()
		visualInstance = preload("res://scenes/debugVisual.tscn").instantiate()
	super()

func delete() -> void:
	super()
	scene.deleteEntity(throughpath.position)

func asNodeOutputTo(node:PathNode) -> PathNode: return throughpath.asNodeOutputTo(node)
func asNodeInputFrom(node:PathNode) -> PathNode: return throughpath.asNodeInputFrom(node)
func asPathNodeAt(_position:Vector2i) -> PathNode: return pathNode

func checkPrevious() -> void: throughpath.checkPreviousOf(pathNode)
func updateNext() -> void: throughpath.updateNextOf(pathNode)

func getSidesOf(node:PathNode) -> Array[PathNode]: return throughpath.getSidesOf(node)
