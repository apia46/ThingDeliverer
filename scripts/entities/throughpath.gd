extends Entity
class_name Throughpath

var references:Array[ThroughpathReference] = []

func ready() -> void:
	references.append(scene.placeEntity(ThroughpathReference, position + Vector2i(-1, 0), U.ROTATIONS.UP))
	references.append(scene.placeEntity(ThroughpathReference, position + Vector2i(-1, 1), U.ROTATIONS.UP))
	references.append(scene.placeEntity(ThroughpathReference, position + Vector2i(0, 1), U.ROTATIONS.UP))
	for ref in references:
		ref.throughpath = self
	super()

func delete() -> void:
	super()
	for ref in references:
		scene.deleteEntity(ref.position)

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/throughpath.tscn").instantiate()
	super()
