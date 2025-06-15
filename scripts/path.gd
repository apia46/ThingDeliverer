extends RefCounted
class_name Path

var id:int
var complete:bool=false
var nodes:Array[Node] = []

func _init(_id:int):
	id = _id

func _to_string() -> String: return str(id)
