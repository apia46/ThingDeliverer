extends RefCounted
class_name Space

const SPACE_CONNECTION_PROBABILITY = 0.17

var position:Vector2i
var chunk:Chunk

var floorVisual:MeshInstance3D

var unlocked:bool = false

var isUpConnected:U.BOOL3
var upConnect:Space
var isLeftConnected:U.BOOL3
var leftConnect:Space

var isRightConnected:U.BOOL3 = U.BOOL3.UNKNOWN
var rightConnect:Space
var isDownConnected:U.BOOL3 = U.BOOL3.UNKNOWN
var downConnect:Space

func _init(_position:Vector2i, _chunk:Chunk) -> void:
	position = _position
	chunk = _chunk
	isLeftConnected = U.toBool3(randf() < SPACE_CONNECTION_PROBABILITY)
	isUpConnected = U.toBool3(randf() < SPACE_CONNECTION_PROBABILITY)

func getSpaceRelative(difference:Vector2i) -> Space:
	var posChunk:Vector2i = position + difference
	if Rect2i(0, 0, Scene.SPACES_PER_CHUNK, Scene.SPACES_PER_CHUNK).has_point(posChunk):
		return chunk.spaces.get(U.v2iunwrap(posChunk, Scene.SPACES_PER_CHUNK))
	else: return chunk.scene.getChunk(chunk.chunkPos + Vector2i(floor(posChunk/float(Scene.SPACES_PER_CHUNK)))).spaces.get(U.v2iunwrap(U.v2iposmod(posChunk, Scene.SPACES_PER_CHUNK), Scene.SPACES_PER_CHUNK))

func updateConnections() -> void:
	if !isRightConnected:
		var space = getSpaceRelative(Vector2i(1,0))
		if space and U.toBool(space.isLeftConnected):
			isRightConnected = U.BOOL3.TRUE
			rightConnect = space
	if !isDownConnected:
		var space = getSpaceRelative(Vector2i(0,1))
		if space and U.toBool(space.isUpConnected):
			isDownConnected = U.BOOL3.TRUE
			downConnect = space
	if !leftConnect:
		leftConnect = getSpaceRelative(Vector2i(-1,0))
		leftConnect.rightConnect = self
		leftConnect.isRightConnected = isLeftConnected
	if !upConnect:
		upConnect = getSpaceRelative(Vector2i(0,-1))
		upConnect.downConnect = self
		upConnect.isDownConnected = isUpConnected

func unlock() -> void:
	unlocked = true
	chunk.scene.unlockedSpaces.append(self)
	if U.toBool(isUpConnected) and !upConnect.unlocked: upConnect.unlock()
	if U.toBool(isRightConnected) and !rightConnect.unlocked: rightConnect.unlock()
	if U.toBool(isDownConnected) and !downConnect.unlocked: downConnect.unlock()
	if U.toBool(isLeftConnected) and !leftConnect.unlocked: leftConnect.unlock()
	floorVisual = preload("res://scenes/floor.tscn").instantiate()
	chunk.add_child(floorVisual)
	floorVisual.position = U.fxz(position * Scene.SPACE_SIZE + Vector2i(4,4))

func positionAbsolute() -> Vector2i: return position * Scene.SPACE_SIZE + chunk.chunkPos*Scene.CHUNK_SIZE
