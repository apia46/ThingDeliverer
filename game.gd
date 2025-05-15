extends Node3D

func _ready() -> void:
	updateCamera()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			$"camera".position -= Vector3(event.relative.x, 0, event.relative.y) * $"camera".position.y * 0.00237
			updateCamera()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$"camera".position.y *= 0.8
				updateCamera()
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and $"camera".position.y < 100:
				$"camera".position.y *= 1.25
				updateCamera()


func updateCamera() -> void:
	# 2y tan 37.5 * 1152/648
	# it did say it was the horizontal fov but i guess it lied
	var screenWidth:float = $"camera".position.y * 2.728273735
	var screenHeight:float = screenWidth * 0.5625
	
	var leftBound:int = floor(($"camera".position.x - 0.5*screenWidth) / Scene.CHUNK_SIZE)
	var rightBound:int = ceil(($"camera".position.x + 0.5*screenWidth) / Scene.CHUNK_SIZE)
	var topBound:int = floor(($"camera".position.z - 0.5*screenHeight) / Scene.CHUNK_SIZE)
	var bottomBound:int = ceil(($"camera".position.z + 0.5*screenHeight) / Scene.CHUNK_SIZE)
	for chunkPosition:Vector2i in $"scene".chunkPositions.duplicate():
		if chunkPosition.x < leftBound or chunkPosition.x >= rightBound or chunkPosition.y < topBound or chunkPosition.y >= bottomBound:
			$"scene".unloadChunk(chunkPosition)
	for x:int in range(leftBound, rightBound):
		for y:int in range(topBound, bottomBound):
			var thisChunkPosition:Vector2i = Vector2i(x, y)
			if thisChunkPosition not in $"scene".chunkPositions:
				$"scene".loadChunk(thisChunkPosition)
