extends Node3D

const FLOOR_MATERIAL:ShaderMaterial = preload("res://resources/floor.tres")
const SCREEN_SIZE:Vector2 = Vector2(1152, 648)

var intendedCameraHeight:float = 20
var upperCameraHeight: float = 20
var effectiveScreenSize:Vector2 = Vector2(54.56548, 30.69308)
var cursorPosition:Vector2i

var currentRotation:U.ROTATIONS = U.ROTATIONS.UP

func _ready() -> void:
	updateCamera()

func _process(delta) -> void:
	$"camera".position.y += (intendedCameraHeight - $"camera".position.y) * delta * 10
	effectiveScreenSize = Vector2($"camera".position.y * 2.728273735, $"camera".position.y * 1.534653976) # 2y tan 37.5
	if abs(intendedCameraHeight / $"camera".position.y - 1) < 0.001 and abs(intendedCameraHeight / $"camera".position.y - 1) > 0.000001:
		$"camera".position.y = intendedCameraHeight
		upperCameraHeight = intendedCameraHeight
		updateCamera()
	
	FLOOR_MATERIAL.set_shader_parameter("interpolation", clamp($"camera".position.y * 0.05 - 0.75, 0, 1))
	
	cursorPosition = floor(U.xz($"camera".position) + (get_viewport().get_mouse_position() / SCREEN_SIZE - U.v2(0.5)) * effectiveScreenSize)
	$"cursor".position = U.fxz(cursorPosition) + U.v3(0.5)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			$"camera".position -= U.fxz(event.relative) * intendedCameraHeight * 0.00237
			updateCamera()
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			placeTile()
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			deleteTile()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP: # zoom in
					if intendedCameraHeight > 1:
						intendedCameraHeight *= 0.8
						updateCamera()
				MOUSE_BUTTON_WHEEL_DOWN: # zoom out
					if intendedCameraHeight < 100:
						intendedCameraHeight *= 1.25
						upperCameraHeight *= 1.25
						updateCamera()
				MOUSE_BUTTON_LEFT:
					placeTile()
				MOUSE_BUTTON_RIGHT:
					deleteTile()
	elif event is InputEventKey:
		if event.is_pressed():
			match event.keycode:
				KEY_E: currentRotation = U.r90(currentRotation)
				KEY_Q: currentRotation = U.r270(currentRotation)

func updateCamera() -> void:
	var intendedEffectiveScreenSize:Vector2 = Vector2(upperCameraHeight * 2.728273735, upperCameraHeight * 1.534653976)
	var chunksBound:Rect2i = U.rectCorners(floor((U.xz($"camera".position) - 0.5*intendedEffectiveScreenSize) / Scene.CHUNK_SIZE),
											ceil((U.xz($"camera".position) + 0.5*intendedEffectiveScreenSize) / Scene.CHUNK_SIZE))
	
	for chunkPosition:Vector2i in $"scene".chunkPositions.duplicate():
		if not chunksBound.has_point(chunkPosition):
			$"scene".unloadChunk(chunkPosition)
	for x:int in range(chunksBound.position.x, chunksBound.end.x):
		for y:int in range(chunksBound.position.y, chunksBound.end.y):
			var thisChunkPosition:Vector2i = Vector2i(x, y)
			$"scene".loadChunk(thisChunkPosition)

func placeTile() -> void:
	$"scene".getChunk(floor(Vector2(cursorPosition) / Scene.CHUNK_SIZE)).newEntity(U.v2iposmod(cursorPosition, Scene.CHUNK_SIZE), currentRotation)

func deleteTile() -> void:
	$"scene".getChunk(floor(Vector2(cursorPosition) / Scene.CHUNK_SIZE)).removeEntity(U.v2iposmod(cursorPosition, Scene.CHUNK_SIZE))
