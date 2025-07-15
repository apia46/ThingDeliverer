extends RefCounted
class_name Path

var id:int
var completed:bool=false
var start:PathNode
var game:Game
var itemType:Items.TYPES

func _init(_id:int, _game:Game, _itemType:Items.TYPES):
	id = _id
	game = _game
	itemType = _itemType

func complete():
	if completed: return
	completed = true
	start.propagatePathCompleteness()
	game.pathComplete()

func uncomplete():
	if !completed: return
	completed = false
	start.propagatePathCompleteness()

func _to_string() -> String: return str(id)
