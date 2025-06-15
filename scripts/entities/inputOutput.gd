extends Entity
class_name InputOutput

var pathNode:PathNode

func ready() -> void:
	pathNode = PathNode.new(self)
	game.addRunningTimer(1, setHeight)
	super()

func setHeight(timeLeft) -> void:
	if !visualInstance: return
	visualInstance.position.y = max(0.5 - timeLeft*2.5, -1)
