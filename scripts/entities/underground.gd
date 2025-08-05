extends Entity
class_name Underground

var pathNode:PathNode

func ready() -> void:
	super()
	checkPrevious()

func delete() -> void:
	pathNode.delete()
	super()

func loadVisuals() -> void:
	super()
	visualInstance.set_surface_override_material(1, pathNode.partialPath.getColorMaterial())

func asPathNodeAt(_position:Vector2i) -> PathNode: return pathNode
