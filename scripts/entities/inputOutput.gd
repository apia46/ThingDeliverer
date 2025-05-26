extends Entity
class_name InputOutput

var pathPoint:PathPoint

func ready(visible:bool) -> void:
	game.addRunningTimer(1, setHeight)
	super(visible)

func setHeight(timeLeft) -> void:
	if !visualInstance: return
	visualInstance.position.y = max(0.5 - timeLeft*2.5, -1)
