extends Entity
class_name InputOutput

var pathNode:PathNode
var pointing:bool = false
var requestPair:RequestPair

func ready() -> void:
	pathNode = PathNode.new(self, position)
	game.addRunningTimer(1, setHeight)
	super()

func setHeight(timeLeft) -> void:
	if !visualInstance: return
	visualInstance.position.y = max(0.5 - timeLeft*2.5, -1)

class RequestPair:
	var input:Inputter
	var output:Outputter
	var completed:bool = false:
		set(value):
			print(value)
			completed = value
	var itemType:Items.TYPES

	func _init(_itemType):
		itemType = _itemType
