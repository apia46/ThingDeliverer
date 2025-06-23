extends Node3D
class_name Game

const FLOOR_MATERIAL:ShaderMaterial = preload("res://resources/floor.tres")
const SCREEN_SIZE:Vector2 = Vector2(1152, 648)
const CAMERA_MOVE_SPEED:float = 5

@onready var scene = $"scene"

var intendedCameraHeight:float = 20
var upperCameraHeight: float = 20
var effectiveScreenSize:Vector2 = Vector2(54.56548, 30.69308)
var cursorPosition:Vector2i

var cycle:float = 0

var objectToPlace:Object = UndergroundInput

var currentRotation:U.ROTATIONS = U.ROTATIONS.UP:
	set(value):
		currentRotation = value
		updateCursor()

var timers:Array[Timer] = []

var paths:Array[Path] = []

var isDebug:bool = true

func _ready() -> void:
	scene.newSpace(Vector2i(0,0))
	scene.newSpace(Vector2i(8,0))
	scene.newSpace(Vector2i(0,8))
	scene.newSpace(Vector2i(8,8))
	newInputOutputs()
	updateCursor()

func _process(delta:float) -> void:
	if Input.is_key_pressed(KEY_A):$"camera".position.x -= delta * CAMERA_MOVE_SPEED * intendedCameraHeight
	if Input.is_key_pressed(KEY_W):$"camera".position.z -= delta * CAMERA_MOVE_SPEED * intendedCameraHeight
	if Input.is_key_pressed(KEY_S):$"camera".position.z += delta * CAMERA_MOVE_SPEED * intendedCameraHeight
	if Input.is_key_pressed(KEY_D):$"camera".position.x += delta * CAMERA_MOVE_SPEED * intendedCameraHeight
	
	$"camera".position.y += (intendedCameraHeight - $"camera".position.y) * delta * 10
	effectiveScreenSize = Vector2($"camera".position.y * 2.728273735, $"camera".position.y * 1.534653976) # 2y tan 37.5
	if abs(intendedCameraHeight / $"camera".position.y - 1) < 0.001 and abs(intendedCameraHeight / $"camera".position.y - 1) > 0.000001:
		$"camera".position.y = intendedCameraHeight
		upperCameraHeight = intendedCameraHeight
	
	FLOOR_MATERIAL.set_shader_parameter("interpolation", clamp($"camera".position.y * 0.05 - 0.75, 0, 1))
	
	cursorPosition = floor(U.xz($"camera".position) + (get_viewport().get_mouse_position() / SCREEN_SIZE - U.v2(0.5)) * effectiveScreenSize)
	$"cursor".position = U.fxz(cursorPosition) + U.v3(0.5)
	
	cycle += 4 * delta
	if cycle >= 1:
		cycle -= 1
	scene.items.updateDisplays()

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			$"camera".position -= U.fxz(event.relative) * intendedCameraHeight * 0.00237
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			# placeDrag, deletedrag
			cursorPosition = floor(U.xz($"camera".position) + (event.position / SCREEN_SIZE - U.v2(0.5)) * effectiveScreenSize)
			var previousCursorPosition:Vector2i = floor(U.xz($"camera".position) + ((event.position - event.relative) / SCREEN_SIZE - U.v2(0.5)) * effectiveScreenSize)
			if abs(event.relative.x) > abs(event.relative.y):
				var dragSign = sign(cursorPosition.x - previousCursorPosition.x)
				for i in abs(cursorPosition.x - previousCursorPosition.x) + 1:
					cursorPosition = previousCursorPosition + Vector2i(i * dragSign, 0)
					if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): place()
					else: delete()
			else:
				var dragSign = sign(cursorPosition.y - previousCursorPosition.y)
				for i in abs(cursorPosition.y - previousCursorPosition.y) + 1:
					cursorPosition = previousCursorPosition + Vector2i(0, i * dragSign)
					if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): place()
					else: delete()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP: tryZoomIn()
				MOUSE_BUTTON_WHEEL_DOWN: tryZoomOut()
				MOUSE_BUTTON_LEFT:place()
				MOUSE_BUTTON_RIGHT: delete()
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

func place() -> Entity:
	var entityPresent: Entity = scene.getEntity(cursorPosition)
	if entityPresent is InputOutput: return null
	if !scene.getSpace(cursorPosition): return null
	return scene.placeEntity(objectToPlace, cursorPosition, currentRotation)

func delete() -> Entity:
	var entityPresent: Entity = scene.getEntity(cursorPosition)
	if entityPresent is InputOutput: return null
	return scene.deleteEntity(cursorPosition)

func tryZoomIn() -> void:
	if intendedCameraHeight > 1:
		intendedCameraHeight *= 0.8

func tryZoomOut() -> void:
	if intendedCameraHeight < 100:
		intendedCameraHeight *= 1.25
		upperCameraHeight *= 1.25

func randomUnlockedTile() -> Vector2i:
	return scene.spaces[scene.spaces.keys()[randi_range(0, len(scene.spaces) - 1)]].position + Vector2i(randi_range(0, Scene.SPACE_SIZE - 1), randi_range(0, Scene.SPACE_SIZE - 1))

func isABadLocation(pos:Vector2i, rot:U.ROTATIONS) -> bool:
	if scene.getEntity(pos): return true
	if !scene.getSpace(pos + U.rotate(Vector2i(0,-1), rot)): return true
	if scene.getEntity(pos + U.rotate(Vector2i(0,-1), rot)): return true
	return false

func newInputOutputs() -> void:
	var path = Path.new(len(paths), self)
	paths.append(path)
	
	var inputPos:Vector2i = randomUnlockedTile()
	var inputRot:U.ROTATIONS = randi_range(0,3) as U.ROTATIONS
	while isABadLocation(inputPos, inputRot):
		inputPos = randomUnlockedTile()
		inputRot = randi_range(0,3) as U.ROTATIONS
	var input:Inputter = scene.placeEntity(Inputter, inputPos, inputRot)
	input.pathNode = PathNode.new(input, inputPos)
	input.pathNode.path = path
	input.pathNode.index = 0
	path.start = input.pathNode
	
	var outputPos:Vector2i = randomUnlockedTile()
	var outputRot:U.ROTATIONS = randi_range(0,3) as U.ROTATIONS
	while outputPos.distance_squared_to(inputPos) < 36 or isABadLocation(outputPos, outputRot):
		outputPos = randomUnlockedTile()
		outputRot = randi_range(0,3) as U.ROTATIONS
	var output:Outputter = scene.placeEntity(Outputter, outputPos, outputRot)
	output.pathNode = PathNode.new(output, outputPos)
	output.pathNode.path = path

func pathComplete() -> void:
	for pathcheck in paths: if !pathcheck.completed:return
	newInputOutputs()

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

func updateCursor():
	$"cursor".mesh = preload("res://meshes/beltStraight.tres")
	$"cursor".rotation.y = U.rotToRad(currentRotation)

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
