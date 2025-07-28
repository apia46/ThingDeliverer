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

func ready() -> void: loadVisuals()

func delete() -> void:
	unloadVisuals()

func loadVisuals() -> void:
	if visualInstance:
		visualInstance.position = U.fxz(position) + U.v3(0.5)
		visualInstance.rotation.y = U.rotToRad(rotation)
		scene.add_child(visualInstance)

func unloadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()

func getEntityRelative(difference:Vector2i, debug:=false) -> Entity:
	if debug: scene.newDebugVisual(position + difference, Color(0, 0.4, 1))
	return scene.getEntity(position + difference)

static func updateEntityVisuals(entity:Entity) -> void: if entity: entity.loadVisuals()

func asNodeOutputTo(_node:PathNode) -> PathNode: return null
func asNodeInputFrom(_node:PathNode) -> PathNode: return null

func getNodeInputFromRelative(node:PathNode, difference:Vector2i) -> PathNode:
	var entity = scene.getEntity(node.position + U.rotate(difference, rotation))
	return entity.asNodeOutputTo(node) if entity else null

func getNodeOutputFromRelative(node:PathNode, difference:Vector2i) -> PathNode:
	var entity = scene.getEntity(node.position + U.rotate(difference, rotation))
	return entity.asNodeInputFrom(node) if entity else null

func previousWillBeDisconnected() -> void: assert(false)
func previousWillBeDeleted() -> void: assert(false)
func checkPrevious() -> void: pass
func updateNext() -> void: pass
func checkNext() -> void: pass # used sparingly

func joinedBefore(_node:PathNode) -> void: pass
