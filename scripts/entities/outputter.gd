extends InputOutput
class_name Outputter

func loadVisuals():
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/output.tscn").instantiate()
	super()

func checkPrevious():
	var previousEntity:Entity = facingThis(getEntityRelative(U.rotate(Vector2i(0,-1), rotation), true))
	if previousEntity:
		var previousPathPoint:PathPoint = previousEntity.getPathPoint(position)
		if previousPathPoint and pathPoint.isDirectlyAfter(previousPathPoint):
			pathPoint.previousEntity = previousEntity
			game.pathComplete(pathPoint.path)
			pathPoint.pathComplete(self)


func facingThis(entity:Entity) -> Entity: # TODO:refactor
	if !entity: return null
	scene.newDebugVisual(entity.position + U.rotate(Vector2i(0,-1), entity.rotation), Color(0, 1, 0.4))
	return entity if (entity is Belt or entity is Inputter) and entity.position + U.rotate(Vector2i(0,-1), entity.rotation) == position else null
