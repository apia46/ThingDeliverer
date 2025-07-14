extends Node3D
class_name Game

const FLOOR_MATERIAL:ShaderMaterial = preload("res://resources/floor.tres")
const CAMERA_MOVE_SPEED:float = 5

@onready var scene = $"scene"
@onready var ui = $"ui"
@onready var cursor = $"ui/SubViewportContainer/cursorViewport/cursor"

var intendedCameraHeight:float = 20
var upperCameraHeight: float = 20
var effectiveScreenSize:Vector2 = Vector2(54.56548, 30.69308)
var cursorPosition:Vector2i

var cycle:float = 0
var timeLeft:float = 60

var objectToPlace:Object = Belt
var undergroundInputStoredNode:PathNode
var undergroundsAvailable = 0:
	set(value):
		undergroundsAvailable = value
		ui.updateUndergroundsCount()

var currentRotation:U.ROTATIONS = U.ROTATIONS.UP:
	set(value):
		currentRotation = value
		setCursor()

var timers:Array[Timer] = []

var paths:Array[Path] = []
var rounds:int = 1
var pathsThisRound:int = 0
var pathsPerRound:int = 5
var paused:bool = false

var cameraPosition:Vector3 = Vector3(0,20,0):
	set(value):
		cameraPosition = value
		$"camera".position = value
		$"ui/SubViewportContainer/cursorViewport/cursorCamera".position = value

var currentDragX:U.BOOL3 = U.BOOL3.UNKNOWN # current drag direction; used for the thing with the belt
var dragStartPos:Vector2i

var isDebug:bool = false

func _ready() -> void:
	for x in range(-2, 2): for y in range(-2, 2):
		scene.newSpace(Vector2i(x*Scene.SPACE_SIZE,y*Scene.SPACE_SIZE))
	newInputOutputs()
	setCursor(Belt)

func _process(delta:float) -> void:
	if Input.is_key_pressed(KEY_A):cameraPosition.x -= delta * CAMERA_MOVE_SPEED * intendedCameraHeight
	if Input.is_key_pressed(KEY_W):cameraPosition.z -= delta * CAMERA_MOVE_SPEED * intendedCameraHeight
	if Input.is_key_pressed(KEY_S):cameraPosition.z += delta * CAMERA_MOVE_SPEED * intendedCameraHeight
	if Input.is_key_pressed(KEY_D):cameraPosition.x += delta * CAMERA_MOVE_SPEED * intendedCameraHeight
	
	cameraPosition.y += (intendedCameraHeight - cameraPosition.y) * delta * 10
	var aspectRatio = float(get_viewport().size.x) / get_viewport().size.y
	effectiveScreenSize = Vector2(cameraPosition.y * 1.534653976 * aspectRatio, cameraPosition.y * 1.534653976) # 2y tan 37.5
	if abs(intendedCameraHeight / cameraPosition.y - 1) < 0.001 and abs(intendedCameraHeight / cameraPosition.y - 1) > 0.000001:
		cameraPosition.y = intendedCameraHeight
		upperCameraHeight = intendedCameraHeight
	
	FLOOR_MATERIAL.set_shader_parameter("interpolation", clamp(cameraPosition.y * 0.05 - 0.75, 0, 1))
	
	cursorPosition = screenspaceToWorldspace(get_viewport().get_mouse_position())
	cursor.position = U.fxz(cursorPosition) + U.v3(0.5)
	
	if paused: cycle += delta
	else: cycle += 4 * delta
	if cycle >= 1:
		cycle -= 1
	scene.items.updateDisplays()
	
	if !paused:
		timeLeft -= delta
	ui.updateTimer()

func _input(event:InputEvent) -> void:
	if paused: return
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			cameraPosition -= U.fxz(event.relative) * intendedCameraHeight * 0.00237
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			# placeDrag, deletedrag
			cursorPosition = screenspaceToWorldspace(event.position)
			var previousCursorPosition:Vector2i = screenspaceToWorldspace(event.position - event.relative)
			
			var readFromCurrentDragX = objectToPlace == Belt and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
			
			if (!(readFromCurrentDragX and U.isKnown(currentDragX)) and abs(event.relative.x) > abs(event.relative.y)) or ((readFromCurrentDragX and U.isKnown(currentDragX)) and U.isTrue(currentDragX)):
				if U.isKnown(currentDragX):
					cursorPosition.y = dragStartPos.y
					previousCursorPosition.y = dragStartPos.y
				var dragSign = sign(cursorPosition.x - previousCursorPosition.x)
				if readFromCurrentDragX and dragSign: currentDragX = U.BOOL3.TRUE
				for i in abs(cursorPosition.x - previousCursorPosition.x) + 1:
					cursorPosition = previousCursorPosition + Vector2i(i * dragSign, 0)
					if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): place()
					else: delete()
			else:
				if U.isKnown(currentDragX):
					cursorPosition.x = dragStartPos.x
					previousCursorPosition.x = dragStartPos.x
				var dragSign = sign(cursorPosition.y - previousCursorPosition.y)
				if readFromCurrentDragX and dragSign: currentDragX = U.BOOL3.FALSE
				for i in abs(cursorPosition.y - previousCursorPosition.y) + 1:
					cursorPosition = previousCursorPosition + Vector2i(0, i * dragSign)
					if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): place()
					else: delete()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP: tryZoomIn()
				MOUSE_BUTTON_WHEEL_DOWN: tryZoomOut()
				MOUSE_BUTTON_LEFT:
					dragStartPos = cursorPosition
					place()
				MOUSE_BUTTON_RIGHT: delete()
		else:
			match event.button_index:
				MOUSE_BUTTON_LEFT: currentDragX = U.BOOL3.UNKNOWN
	elif event is InputEventKey:
		if event.is_pressed():
			match event.keycode:
				KEY_E:
					currentRotation = U.r90(currentRotation)
					if U.isKnown(currentDragX):
						dragStartPos = screenspaceToWorldspace(get_viewport().get_mouse_position())
						currentDragX = U.bool3not(currentDragX)
				KEY_Q:
					currentRotation = U.r270(currentRotation)
					if U.isKnown(currentDragX):
						dragStartPos = screenspaceToWorldspace(get_viewport().get_mouse_position())
						currentDragX = U.bool3not(currentDragX)
				KEY_F: newInputOutputs()
				KEY_F3: isDebug = !isDebug
				KEY_SHIFT:
					if intendedCameraHeight > 50: intendedCameraHeight = 20
					else: intendedCameraHeight = 76.2939453125; upperCameraHeight = 76.2939453125

func place() -> Entity:
	if paused: return
	var entityPresent: Entity = scene.getEntity(cursorPosition)
	if entityPresent is InputOutput: return null
	if !scene.getSpace(cursorPosition): return null
	if objectToPlace == UndergroundOutput and entityPresent is UndergroundInput: return null
	if objectToPlace == Belt and entityPresent is UndergroundOutput: return null
	var result = scene.placeEntity(objectToPlace, cursorPosition, currentRotation, objectToPlace != UndergroundOutput)
	if result is UndergroundInput:
		if undergroundsAvailable == 0: return
		undergroundsAvailable -= 1
		undergroundInputStoredNode = result.pathNode
		setCursor(UndergroundOutput)
	elif result is UndergroundOutput:
		result.pathNode = PathNode.new(result, result.position)
		result.pathNode.previousNode = undergroundInputStoredNode
		undergroundInputStoredNode.nextNode = result.pathNode
		result.ready()
		setCursor(Belt)
	return result

func delete() -> Entity:
	var entityPresent: Entity = scene.getEntity(cursorPosition)
	if entityPresent is InputOutput: return null
	if entityPresent is UndergroundInput: undergroundsAvailable += 1
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
	# should have space
	if scene.getEntity(pos): return true
	# should be possible
	if !scene.getSpace(pos + U.rotate(Vector2i(0,-1), rot)): return true
	if scene.getEntity(pos + U.rotate(Vector2i(0,-1), rot)): return true
	# be out in the open
	if scene.getEntity(pos + U.rotate(Vector2i(1,0), rot)) and randf() > 0.6: return true
	if scene.getEntity(pos + U.rotate(Vector2i(-1,0), rot)) and randf() > 0.6: return true
	# not too close to edge
	if !scene.getSpace(pos + Vector2i(-3, 0)) and randf() > 0.4: return true
	if !scene.getSpace(pos + Vector2i(3, 0)) and randf() > 0.4: return true
	if !scene.getSpace(pos + Vector2i(0, 3)) and randf() > 0.4: return true
	if !scene.getSpace(pos + Vector2i(0, -3)) and randf() > 0.4: return true
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
	pathsThisRound += 1
	if pathsThisRound == pathsPerRound:
		timeLeft += 50
		ui.updateRoundsCount()
		paused = true
		ui.showEndRoundScreen()
		setCursor()
	else: newInputOutputs()
	ui.updatePathsCount()

func nextRound() -> void:
	rounds += 1
	pathsThisRound = 0
	ui.updateRoundsCount()
	ui.updatePathsCount()
	paused = false
	ui.hideEndRoundScreen()
	for _i in 4: randomNewSpace()
	newInputOutputs()
	setCursor()

func randomNewSpace() -> void:
	while true:
		var space:Space = scene.spaces[scene.spaces.keys()[randi_range(0, len(scene.spaces) - 1)]]
		var randomPosition = space.position + [Vector2i(-Scene.SPACE_SIZE,0),Vector2i(Scene.SPACE_SIZE,0),Vector2i(0,-Scene.SPACE_SIZE),Vector2i(0,Scene.SPACE_SIZE)][randi_range(0,3)]
		if scene.newSpace(randomPosition): return

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

func setCursor(object:Variant=null) -> void:
	if object:
		if (object == UndergroundOutput) != (objectToPlace == UndergroundOutput): currentRotation = U.r180(currentRotation)
		objectToPlace = object
		match objectToPlace:
			Belt: cursor.mesh = preload("res://meshes/beltStraight.tres")
			UndergroundInput: cursor.mesh = preload("res://meshes/undergroundInput.tres")
			UndergroundOutput: cursor.mesh = preload("res://meshes/undergroundOutput.tres")
	cursor.visible = !paused
	cursor.rotation.y = U.rotToRad(currentRotation)

func screenspaceToWorldspace(pos:Vector2) -> Vector2i:
	return floor(U.xz(cameraPosition) + (pos / Vector2(get_viewport().size) - U.v2(0.5)) * effectiveScreenSize)

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
