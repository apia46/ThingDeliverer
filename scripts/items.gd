extends Node3D
class_name Items

enum TYPES {BOX}
@onready var game = get_node("/root/game")
@onready var multiMeshIntances:Array[MultiMeshInstance3D] = [$"box"]

var displays:Array[Array] = [[]]

func updateDisplays():
	var i:int = 0
	for type:Array[Display] in displays:
		var multimesh:MultiMesh = multiMeshIntances[i].multimesh
		multimesh.instance_count = len(type)
		for display in type:
			multimesh.set_instance_transform_2d(display.index, Transform2D(0, display.position))
		
		i += 1

func addDisplay(type:TYPES, pos:Vector2i, direction: U.ROTATIONS) -> Display:
	var display:Display = Display.new(type, pos, direction, len(displays[type]))
	displays[type].append(display)
	return display

func removeDisplay(display:Display) -> void:
	displays[display.type].pop_at(display.index)
	for i in range(display.index, len(displays[display.type])): displays[display.type][i].index -= 1

class Display:
	extends RefCounted
	var type:TYPES
	var position:Vector2i
	var direction:U.ROTATIONS
	var index:int
	
	func _init(_type:TYPES, _position:Vector2i, _direction:U.ROTATIONS, _index:int) -> void:
		type = _type
		position = _position
		direction = _direction
		index = _index
		print(index)
	
