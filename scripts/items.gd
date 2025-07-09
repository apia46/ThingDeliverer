extends Node3D
class_name Items

const ONE_OVER_LOG_TWO = 1 / log(2)
const DISAPPEAR_TRANSFORM = Transform3D(Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0))

enum TYPES {BOX}
@onready var game = get_node("/root/game")
@onready var multiMeshInstances:Array[MultiMeshInstance3D] = [$"box"]

var displays:Array[Array] = [[]]
var displayCounts = [32]
func updateDisplays():
	var i:int = 0
	for type:Array[Display] in displays:
		var multimesh:MultiMesh = multiMeshInstances[i].multimesh
		if len(type) >= displayCounts[i]:
			displayCounts[i] = displayCounts[i] << 1
			multimesh.instance_count = displayCounts[i]
		for display in type:
			multimesh.set_instance_transform(display.index, Transform3D(Basis.IDENTITY, U.fxz(display.position) + U.fxz(U.rotatef(Vector2(0, -game.cycle), display.direction))))
		
		i += 1

func addDisplay(type:TYPES, pos:Vector2i, direction: U.ROTATIONS) -> Display:
	var display:Display = Display.new(type, pos, direction, len(displays[type]))
	displays[type].append(display)
	return display

func removeDisplay(display:Display) -> Display:
	multiMeshInstances[display.type].multimesh.set_instance_transform(len(displays[display.type]), DISAPPEAR_TRANSFORM)
	displays[display.type].pop_at(display.index)
	for i in range(display.index, len(displays[display.type])): displays[display.type][i].index -= 1
	return null

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
	
