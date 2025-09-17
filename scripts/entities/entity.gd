extends RefCounted
class_name Entity

static func getName() -> String: return "Entity"

var game:Game
var scene:Scene

var deleted:bool = false

var visualInstance:MeshInstance3D
var position:Vector2i
var rotation:U.ROTATIONS

func _init(_scene:Scene, _position:Vector2i, _rotation:U.ROTATIONS) -> void:
	scene = _scene
	game = scene.game
	position = _position
	rotation = _rotation

func ready() -> void:
	loadVisuals()

func delete() -> void:
	unloadVisuals()
	deleted = true

func loadVisuals() -> void:
	if visualInstance:
		visualInstance.position = U.fxz(position) + U.v3(0.5)
		visualInstance.rotation.y = U.rotToRad(rotation)
		scene.add_child(visualInstance)

func unloadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()

func getEntityRelative(difference:Vector2i, _debug:=false) -> Entity:
	#if debug: scene.newDebugVisual(position + U.rotate(difference, rotation), Color(0, 0.4, 1))
	return scene.getEntity(position + U.rotate(difference, rotation))

func getPathNodeRelative(difference:Vector2i) -> PathNode:
	var entity:Entity = scene.getEntity(position + U.rotate(difference, rotation))
	if entity: return entity.asPathNodeAt(position + U.rotate(difference, rotation))
	else: return null

static func updateEntityVisuals(entity:Entity) -> void: if entity: entity.loadVisuals()

func asNodeOutputTo(_node:PathNode) -> PathNode: return null
func asNodeInputFrom(_node:PathNode) -> PathNode: return null
func asPathNodeAt(_position:Vector2i) -> PathNode: return null

func getNodeInputFromRelative(node:PathNode, difference:Vector2i) -> PathNode:
	var entity = scene.getEntity(node.position + U.rotate(difference, rotation))
	return entity.asNodeOutputTo(node) if entity else null

func getNodeOutputFromRelative(node:PathNode, difference:Vector2i) -> PathNode:
	var entity = scene.getEntity(node.position + U.rotate(difference, rotation))
	return entity.asNodeInputFrom(node) if entity else null

func checkPrevious() -> void: return
func updateNext() -> void: return
func checkNext() -> void: loadVisuals() # use sparingly. set to load visuals for clarity of debug and also might be useful idk

func hoverInfo(append:int=0) -> String:
	return H.debugAttribute(game.isDebug, "position", position, append)

func getSidesOf(_pathNode:PathNode) -> Array[PathNode]:
	assert(false)
	return []
