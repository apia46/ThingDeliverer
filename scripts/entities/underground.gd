extends Entity
class_name Underground

var pathNode:PathNode

func delete() -> void:
	pathNode.disconnectFromPath(true)
	super()
