extends MultiMeshInstance3D
class_name SpaceVisuals

var spaceVisuals:Array[SpaceVisual] = []

func addSpaceVisual(pos:Vector2i) -> SpaceVisual:
	var visual = SpaceVisual.new(pos, len(spaceVisuals))
	spaceVisuals.append(visual)
	recalculateMultimesh()
	return visual

func recalculateMultimesh():
	multimesh.instance_count = len(spaceVisuals)
	for visual in spaceVisuals: multimesh.set_instance_transform(visual.index, Transform3D(Basis.IDENTITY, U.fxz(visual.pos)))

class SpaceVisual:
	extends RefCounted
	
	var pos:Vector2i
	var index:int
	
	func _init(_pos:Vector2i, _index:int) -> void:
		pos = _pos
		index = _index
