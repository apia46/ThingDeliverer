extends Entity
class_name Underground

var pathNode:PathNode

func ready() -> void:
	super()
	checkPrevious()

func delete() -> void:
	pathNode.delete()
	super()
