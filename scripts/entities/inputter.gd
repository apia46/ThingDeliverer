extends InputOutput
class_name Inputter

var itemDisplay:Items.Display

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/input.tscn").instantiate()
	
	if pathNode.isPathComplete() and !itemDisplay: itemDisplay = scene.items.addDisplay(Items.TYPES.BOX, position, rotation)
	elif itemDisplay: itemDisplay = scene.items.removeDisplay(itemDisplay)
	super()

func updateNext() -> void:
	var node = getNodeInputFromRelative(pathNode, Vector2i(0,-1))
	if node: node.entity.checkPrevious()

func asNodeOutputTo(node:PathNode) -> PathNode: return pathNode if node.position == position + U.rotate(Vector2i(0,-1), rotation) else null
