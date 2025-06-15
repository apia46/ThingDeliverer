extends InputOutput
class_name Outputter

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/output.tscn").instantiate()
	super()

func checkPrevious() -> void:
	var previousNode:PathNode = getNodeInputFromRelative(Vector2i(0,-1))
	if previousNode.path:
		if pathNode.isDirectlyAfter(previousNode):
			pathNode.joinAfter(previousNode)
			game.pathComplete(pathNode.path)


func facingThis(entity:Entity) -> Entity: # TODO:refactor
	if !entity: return null
	scene.newDebugVisual(entity.position + U.rotate(Vector2i(0,-1), entity.rotation), Color(0, 1, 0.4))
	return entity if (entity is Belt or entity is Inputter) and entity.position + U.rotate(Vector2i(0,-1), entity.rotation) == position else null

func asNodeInputFrom(pos:Vector2i) -> PathNode: return pathNode if pos == position + U.rotate(Vector2i(0,1), rotation) else null
