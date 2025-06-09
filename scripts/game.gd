extends Node3D
class_name Game

const FLOOR_MATERIAL:ShaderMaterial = preload("res://resources/floor.tres")
const SCREEN_SIZE:Vector2 = Vector2(1152, 648)
const CAMERA_MOVE_SPEED:float = 5

var intendedCameraHeight:float = 20
var upperCameraHeight: float = 20
var effectiveScreenSize:Vector2 = Vector2(54.56548, 30.69308)
var cursorPosition:Vector2i

var currentRotation:U.ROTATIONS = U.ROTATIONS.UP

var timers:Array[Timer] = []

var paths:int = 0

var isDebug:bool = false

func _ready() -> void:
	updateCamera()
	$"scene".getChunk(Vector2i(0,0)).allocatedSpaces[5].unlock()
	$"scene".getChunk(Vector2i(0,0)).allocatedSpaces[6].unlock()
	$"scene".getChunk(Vector2i(0,0)).allocatedSpaces[9].unlock()
	$"scene".getChunk(Vector2i(0,0)).allocatedSpaces[10].unlock()

func _process(delta:float) -> void:
	if Input.is_key_pressed(KEY_A):$"camera".position.x -= delta * CAMERA_MOVE_SPEED * intendedCameraHeight; updateCamera()
	if Input.is_key_pressed(KEY_W):$"camera".position.z -= delta * CAMERA_MOVE_SPEED * intendedCameraHeight; updateCamera()
	if Input.is_key_pressed(KEY_S):$"camera".position.z += delta * CAMERA_MOVE_SPEED * intendedCameraHeight; updateCamera()
	if Input.is_key_pressed(KEY_D):$"camera".position.x += delta * CAMERA_MOVE_SPEED * intendedCameraHeight; updateCamera()
	
	$"camera".position.y += (intendedCameraHeight - $"camera".position.y) * delta * 10
	effectiveScreenSize = Vector2($"camera".position.y * 2.728273735, $"camera".position.y * 1.534653976) # 2y tan 37.5
	if abs(intendedCameraHeight / $"camera".position.y - 1) < 0.001 and abs(intendedCameraHeight / $"camera".position.y - 1) > 0.000001:
		$"camera".position.y = intendedCameraHeight
		upperCameraHeight = intendedCameraHeight
		updateCamera()
	$"map".update()
	
	FLOOR_MATERIAL.set_shader_parameter("interpolation", clamp($"camera".position.y * 0.05 - 0.75, 0, 1))
	
	cursorPosition = floor(U.xz($"camera".position) + (get_viewport().get_mouse_position() / SCREEN_SIZE - U.v2(0.5)) * effectiveScreenSize)
	$"cursor".position = U.fxz(cursorPosition) + U.v3(0.5)

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			$"camera".position -= U.fxz(event.relative) * intendedCameraHeight * 0.00237
			updateCamera()
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			placeEntity(Belt, cursorPosition, currentRotation)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			deleteEntity()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP: tryZoomIn()
				MOUSE_BUTTON_WHEEL_DOWN: tryZoomOut()
				MOUSE_BUTTON_LEFT: placeEntity(Belt, cursorPosition, currentRotation)
				MOUSE_BUTTON_RIGHT: deleteEntity()
	elif event is InputEventKey:
		if event.is_pressed():
			match event.keycode:
				KEY_E: currentRotation = U.r90(currentRotation)
				KEY_Q: currentRotation = U.r270(currentRotation)
				KEY_F: newInputOutputs()
				KEY_F3: isDebug = !isDebug
				KEY_SHIFT:
					if intendedCameraHeight > 50: intendedCameraHeight = 20
					else: intendedCameraHeight = 76.2939453125; upperCameraHeight = 76.2939453125
					updateCamera()

func tryZoomIn() -> void:
	if intendedCameraHeight > 1:
		intendedCameraHeight *= 0.8
		updateCamera()

func tryZoomOut() -> void:
	if intendedCameraHeight < 100:
		intendedCameraHeight *= 1.25
		upperCameraHeight *= 1.25
		updateCamera()

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

func getEntity(pos:Vector2i) -> Entity:
	return $"scene".getChunk(floor(Vector2(pos) / Scene.CHUNK_SIZE)).entities.get(U.v2iposmod(pos, Scene.CHUNK_SIZE))

func placeEntity(type:Variant, pos:Vector2i, rot:U.ROTATIONS, authority:=false) -> Entity:
	return $"scene".getChunk(floor(Vector2(pos) / Scene.CHUNK_SIZE)).newEntity(type, U.v2iposmod(pos, Scene.CHUNK_SIZE), rot, authority)

func deleteEntity(authority:=false) -> void:
	$"scene".getChunk(floor(Vector2(cursorPosition) / Scene.CHUNK_SIZE)).removeEntity(U.v2iposmod(cursorPosition, Scene.CHUNK_SIZE), authority)

func newInputOutputs() -> void:
	var inputPos:Vector2i = Vector2i(randi_range(-8, 7), randi_range(-8, 7))
	while getEntity(inputPos): inputPos = Vector2i(randi_range(-8, 7), randi_range(-8, 7))
	var input:Inputter = placeEntity(Inputter, inputPos, randi_range(0, 3), true)
	input.pathPoint = PathPoint.new(paths, 0)
	
	var outputPos:Vector2i = Vector2i(randi_range(-8, 7), randi_range(-8, 7))
	while getEntity(outputPos): outputPos = Vector2i(randi_range(-8, 7), randi_range(-8, 7))
	var output:Outputter = placeEntity(Outputter, outputPos, randi_range(0, 3), true)
	output.pathPoint = PathPoint.new(paths, -1)
	
	paths += 1

func addRunningTimer(time:float, running:Callable):
	var timer = RunningTimer.new()
	timer.one_shot = true
	timer.index = len(timers)
	timer.running = running
	timer.game = self
	timer.connect("timeout", timer._timeout)
	add_child(timer)
	timer.start(time)
	timers.append(timer)

class RunningTimer:
	extends Timer
	var game:Game
	var running:Callable
	var end:Callable
	var index:int
	
	func _process(_delta: float) -> void: if running.get_object(): running.call(time_left)
	
	func _timeout() -> void:
		if end: end.call()
		queue_free()
		for i in range(index+1, len(game.timers)):
			game.timers[i].index -= 1
		game.timers.pop_at(index)
