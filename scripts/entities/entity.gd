extends RefCounted
class_name Entity

var scene:Scene
var chunk:Chunk

var visualInstance:MeshInstance3D
var position:Vector2i # position in chunk
var rotation:U.ROTATIONS

func _init(_chunk:Chunk, _position:Vector2i, _rotation:U.ROTATIONS) -> void:
	chunk = _chunk
	scene = chunk.scene
	position = _position
	rotation = _rotation

func loadVisuals() -> void:
	if visualInstance:
		visualInstance.position = U.fxz(position) + U.v3(0.5)
		visualInstance.rotation.y = U.rotToRad(rotation)
		chunk.add_child(visualInstance)

func unloadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()

func getEntityRelative(difference:Vector2i):
	var posChunk:Vector2i = position + difference
	if Rect2i(0, 0, Scene.CHUNK_SIZE, Scene.CHUNK_SIZE).has_point(posChunk):
		return chunk.entities.get(posChunk)
	else: return scene.getChunk(chunk.chunkPos + Vector2i(floor(posChunk/float(Scene.CHUNK_SIZE)))).entities.get(U.v2iposmod(posChunk, Scene.CHUNK_SIZE))
