extends Entity
class_name Underground

var pathNode:PathNode

func delete() -> void:
	pathNode.delete()
	super()
