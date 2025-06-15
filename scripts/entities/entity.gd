extends RefCounted
class_name Entity

var game:Game
var scene:Scene

var visualInstance:MeshInstance3D
var position:Vector2i # position in chunk
var rotation:U.ROTATIONS

func _init(_scene:Scene, _position:Vector2i, _rotation:U.ROTATIONS) -> void:
	scene = _scene
	game = scene.game
	position = _position
	rotation = _rotation

func ready(visible:bool) -> void:
	if visible: loadVisuals()

func delete() -> void:
	unloadVisuals()

func loadVisuals() -> void:
	if visualInstance:
		visualInstance.position = U.fxz(position) + U.v3(0.5)
		visualInstance.rotation.y = U.rotToRad(rotation)
		scene.add_child(visualInstance)

func unloadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()

func getEntityRelative(difference:Vector2i, debug:=false):
	if debug: scene.newDebugVisual(position + difference, Color(0, 0.4, 1))
	return scene.getEntity(position + difference)

static func updateEntityVisuals(entity:Entity) -> void: if entity: entity.loadVisuals()

func getPathPoint(_pos:Vector2i) -> PathPoint: return self.pathPoint # jank
