extends RefCounted
class_name Path

var id:int
var completed:bool=false

func _init(_id:int):
	id = _id

func _to_string() -> String: return "<Path " + str(id) + ("C" if completed else "U") + ">"
