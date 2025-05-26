extends RefCounted
class_name PathPoint

var path:int
var point:int
var complete:bool=false
var previousEntity:Entity

func _init(_path:int, _point:int, _previousEntity:Entity=null):
	path = _path
	point = _point
	previousEntity = _previousEntity

func generateNext(entity:Entity) -> PathPoint:
	return PathPoint.new(path, point + 1, entity)

func isDirectlyAfter(candidatePrevious:PathPoint) -> bool:
	return candidatePrevious and path == candidatePrevious.path and (point == candidatePrevious.point+1 or point == -1) # outputs are at -1

func isBefore(candidateAfter:PathPoint) -> bool:
	return candidateAfter and path == candidateAfter.path and point < candidateAfter.point

func pathComplete(thisEntity:Entity): # such a hack
	complete = true
	thisEntity.loadVisuals()
	if previousEntity: previousEntity.getPathPoint(thisEntity.positionAbsolute()).pathComplete(previousEntity)

func pathUncomplete(thisEntity:Entity):
	complete = false
	thisEntity.loadVisuals()
	if previousEntity: previousEntity.getPathPoint(thisEntity.positionAbsolute()).pathUncomplete(previousEntity)
