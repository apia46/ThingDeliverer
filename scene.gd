extends Node3D
class_name Scene
const CHUNK = preload("res://chunk.tscn");
const CHUNK_SIZE:float = 32

var chunks:Array[Chunk] = []
var chunkPositions:Array[Vector2i] = []

func loadChunk(chunkPos:Vector2i) -> void:
	var chunk:Chunk = CHUNK.instantiate()
	chunk.position = Vector3(chunkPos.x * 32 + 16, 0, chunkPos.y * 32 + 16)
	chunks.append(chunk)
	chunkPositions.append(chunkPos)
	add_child(chunk)

func unloadChunk(chunkPos:Vector2i) -> void:
	var index:int = chunkPositions.find(chunkPos)
	chunks.pop_at(index).queue_free()
	chunkPositions.pop_at(index)
