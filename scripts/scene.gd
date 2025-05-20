extends Node3D
class_name Scene
const CHUNK = preload("res://scenes/chunk.tscn");
const CHUNK_SIZE:int = 32

var chunks:Array[Chunk] = []
var chunkPositions:Array[Vector2i] = []

func loadChunk(chunkPos:Vector2i) -> void:
	var index:int = chunkPositions.find(chunkPos)
	if index == -1:
		var chunk:Chunk = CHUNK.instantiate().setProperties(chunkPos)
		chunks.append(chunk)
		chunkPositions.append(chunkPos)
		add_child(chunk)
	else: chunks[index].loadVisuals()

func unloadChunk(chunkPos:Vector2i) -> void:
	chunks[chunkPositions.find(chunkPos)].unloadVisuals()

func getChunk(chunkPos:Vector2i) -> Chunk:
	return chunks[chunkPositions.find(chunkPos)]
