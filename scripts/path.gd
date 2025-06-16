extends RefCounted
class_name Path

var id:int
var completed:bool=false
var start:PathNode
var game:Game

func _init(_id:int, _game:Game):
	id = _id
	game = _game

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
