extends Node3D
class_name Game

const FLOOR_MATERIAL:ShaderMaterial = preload("res://resources/floor.tres")
const CAMERA_MOVE_SPEED:float = 2

@onready var menu:Menu = $"/root/menu"
@onready var scene:Scene = $"scene"
@onready var ui = $"ui"
@onready var cursor = $"ui/SubViewportContainer/cursorViewport/cursor"
@onready var hover:H = $"hover"

var intendedCameraHeight:float = 20
var upperCameraHeight: float = 20
var effectiveScreenSize:Vector2 = Vector2(54.56548, 30.69308)
var cursorPosition:Vector2i

var cycle:float = 0
var timeLeft:float = 15
var timeSinceStart:float = 0

var objectToPlace:Object = Belt
var undergroundInputStoredNode:PathNode
var undergroundInputStoredNode2:PathNode
var twicePlacing:bool = false
var undergroundsAvailable = 0:
	set(value):
		undergroundsAvailable = value
		ui.updateUndergroundsCount()

var currentRotation:U.ROTATIONS = U.ROTATIONS.UP:
	set(value):
		currentRotation = value
		setCursor()

var timers:Array[Timer] = []

var requestPairs:Array[InputOutput.RequestPair] = []
var rounds:int = 1
var pathsThisRound:int = 0
var pathsPerRound:int = 5
var paused:bool = false
var trulyPaused:bool = false # stop anims fully

var partialPathIdIncr:int = 0

var itemTypesUnlocked:Array[Items.TYPES] = [Items.TYPES.BOX]
var itemTypesLocked:Array[Items.TYPES] = [Items.TYPES.FRIDGE, Items.TYPES.GYRO, Items.TYPES.MAGNET, Items.TYPES.CHEMICAL, Items.TYPES.ARTIFACT, Items.TYPES.PARTICLE]
var unlockedItemTypeThisRound:bool = false

var cameraPosition:Vector3 = Vector3(0,20,0):
	set(value):
		cameraPosition = value
		$"camera".position = value
		$"ui/SubViewportContainer/cursorViewport/cursorCamera".position = value

var currentDragX:U.BOOL3 = U.BOOL3.UNKNOWN # current drag direction; used for the thing with the belt
var dragStartPos:Vector2i

var isDebug:bool = false

const HOVER_INSPEED:float = 2
const HOVER_OUTSPEED:float = 2
var hoverPosition:Vector2i = Vector2i(0, 0)
var hoverTime:float = 0

func _ready() -> void:
	for x in range(-2, 2): for y in range(-2, 2):
		scene.newSpace(Vector2i(x*Scene.SPACE_SIZE,y*Scene.SPACE_SIZE))
	newInputOutputs()
	setCursor(Belt)
	menu.consoleSet("Game Started")

func _process(delta:float) -> void:
	var previousCursorPosition:Vector2i = cursorPosition
	cursorPosition = screenspaceToWorldspace(get_viewport().get_mouse_position())
	if !paused and !Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_A):
			cameraPosition.x -= delta * CAMERA_MOVE_SPEED * intendedCameraHeight
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): heldClick(previousCursorPosition)
		if Input.is_key_pressed(KEY_W):
			cameraPosition.z -= delta * CAMERA_MOVE_SPEED * intendedCameraHeight
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): heldClick(previousCursorPosition)
		if Input.is_key_pressed(KEY_S):
			cameraPosition.z += delta * CAMERA_MOVE_SPEED * intendedCameraHeight
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): heldClick(previousCursorPosition)
		if Input.is_key_pressed(KEY_D):
			cameraPosition.x += delta * CAMERA_MOVE_SPEED * intendedCameraHeight
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): heldClick(previousCursorPosition)
	
	cameraPosition.y += (intendedCameraHeight - cameraPosition.y) * delta * 10
	var aspectRatio = float(get_viewport().size.x) / get_viewport().size.y
	effectiveScreenSize = Vector2(cameraPosition.y * 1.534653976 * aspectRatio, cameraPosition.y * 1.534653976) # 2y tan 37.5
	if abs(intendedCameraHeight / cameraPosition.y - 1) < 0.001 and abs(intendedCameraHeight / cameraPosition.y - 1) > 0.000001:
		cameraPosition.y = intendedCameraHeight
		upperCameraHeight = intendedCameraHeight
	
	FLOOR_MATERIAL.set_shader_parameter("interpolation", clamp(cameraPosition.y * 0.05 - 0.75, 0, 1))
	
	if objectToPlace == UndergroundOutput:
		var inputPosition = undergroundInputStoredNode.position
		if U.isVertical(currentRotation):
			cursorPosition.x = previousCursorPosition.x
			if currentRotation == U.ROTATIONS.DOWN: cursorPosition.y = clamp(cursorPosition.y, inputPosition.y - 5, inputPosition.y - 1)
			else: cursorPosition.y = clamp(cursorPosition.y, inputPosition.y + 1, inputPosition.y + 5)
		if U.isHorizontal(currentRotation):
			cursorPosition.y = previousCursorPosition.y
			if currentRotation == U.ROTATIONS.RIGHT: cursorPosition.x = clamp(cursorPosition.x, inputPosition.x - 5, inputPosition.x - 1)
			else: cursorPosition.x = clamp(cursorPosition.x, inputPosition.x + 1, inputPosition.x + 5)
	cursor.position = U.fxz(cursorPosition) + U.v3(0.5)
	
	if !paused: cycle += 4 * delta
	elif !trulyPaused: cycle += delta
	if cycle >= Items.SPACES_PER_ITEM:
		cycle -= Items.SPACES_PER_ITEM
	scene.items.updateDisplays()
	
	if !paused && rounds > 1:
		timeLeft -= delta
		if timeLeft < 0: lose()
	ui.updateTimer()

	timeSinceStart += delta

	var hovered:Entity = scene.getEntity(cursorPosition)
	if hovered and !paused:
		hoverPosition = cursorPosition
		hover.setHover(hovered)
		if cursorPosition == previousCursorPosition: hoverTime += delta * HOVER_INSPEED
		else: hoverTime -= delta * HOVER_OUTSPEED
	else: hoverTime -= delta * HOVER_OUTSPEED
	hoverTime = clampf(hoverTime, 0, 1)
	hover.modulate.a = (hoverTime - 0.6) * 3
	cursor.transparency = (hoverTime - 0.6) * 3
	hover.position = worldspaceToScreenspace(Vector2(hoverPosition) + Vector2(0.5, 0.8)) + Vector2(8, 8)
	var bottomRightCorner:Vector2 = hover.position + hover.size - Vector2(get_viewport().size) + Vector2(32, 14) # add bottom right expand margins and some margins
	if bottomRightCorner.y > 0: hover.position.y = worldspaceToScreenspace(Vector2(hoverPosition) + Vector2(0.5, 0.2)).y - hover.size.y - 8
	if bottomRightCorner.x > 0:
		for child in hover.get_children(): child.size_flags_horizontal = 8
		hover.position.x -= hover.size.x + 16
	else: for child in hover.get_children(): child.size_flags_horizontal = 0

func heldClick(previousCursorPosition:Vector2i) -> void:
	# placeDrag, deletedrag
	
	var readFromCurrentDragX = objectToPlace == Belt and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if (!(readFromCurrentDragX and U.isKnown(currentDragX)) and abs(cursorPosition.x-previousCursorPosition.x) > abs(cursorPosition.y-previousCursorPosition.y)) or ((readFromCurrentDragX and U.isKnown(currentDragX)) and U.isTrue(currentDragX)):
		if U.isKnown(currentDragX):
			cursorPosition.y = dragStartPos.y
			previousCursorPosition.y = dragStartPos.y
		var dragSign = sign(cursorPosition.x - previousCursorPosition.x)
		if readFromCurrentDragX and dragSign: currentDragX = U.BOOL3.TRUE
		for i in abs(cursorPosition.x - previousCursorPosition.x):
			cursorPosition = previousCursorPosition + Vector2i((i+1) * dragSign, 0)
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): place()
			else: delete()
	else:
		if U.isKnown(currentDragX):
			cursorPosition.x = dragStartPos.x
			previousCursorPosition.x = dragStartPos.x
		var dragSign = sign(cursorPosition.y - previousCursorPosition.y)
		if readFromCurrentDragX and dragSign: currentDragX = U.BOOL3.FALSE
		for i in abs(cursorPosition.y - previousCursorPosition.y):
			cursorPosition = previousCursorPosition + Vector2i(0, (i+1) * dragSign)
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): place()
			else: delete()

func _input(event:InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE and !trulyPaused: menu.togglePause()
	if paused: return
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			cameraPosition -= U.fxz(event.relative) * intendedCameraHeight * 0.00237
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			cursorPosition = screenspaceToWorldspace(event.position)
			heldClick(screenspaceToWorldspace(event.position - event.relative))
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
			if objectToPlace != UndergroundOutput:
				match event.keycode:
					KEY_E: currentRotation = U.r90(currentRotation); restartDragFromHere()
					KEY_Q: currentRotation = U.r270(currentRotation); restartDragFromHere()
					KEY_W: if Input.is_key_pressed(KEY_SHIFT): currentRotation = U.ROTATIONS.UP; restartDragFromHere()
					KEY_A: if Input.is_key_pressed(KEY_SHIFT): currentRotation = U.ROTATIONS.LEFT; restartDragFromHere()
					KEY_S: if Input.is_key_pressed(KEY_SHIFT): currentRotation = U.ROTATIONS.DOWN; restartDragFromHere()
					KEY_D: if Input.is_key_pressed(KEY_SHIFT): currentRotation = U.ROTATIONS.RIGHT; restartDragFromHere()
			match event.keycode:
				KEY_F3: isDebug = !isDebug
				KEY_K: lose()
				KEY_SPACE:
					if intendedCameraHeight > 50: intendedCameraHeight = 20
					else: intendedCameraHeight = 76.2939453125; upperCameraHeight = 76.2939453125

func restartDragFromHere():
	hoverTime = 0
	if U.isKnown(currentDragX):
		dragStartPos = screenspaceToWorldspace(get_viewport().get_mouse_position())
		currentDragX = U.bool3not(currentDragX)

func place(placePosition:Vector2i=cursorPosition) -> Entity:
	if paused: return
	hoverTime = 0
	var entityPresent: Entity = scene.getEntity(placePosition)
	if entityPresent is InputOutput: return null
	if !scene.getSpace(placePosition): return null
	if objectToPlace == UndergroundOutput and entityPresent is UndergroundInput: return null
	if objectToPlace == UndergroundInput and undergroundsAvailable == 0 and !isDebug: return null
	var result = scene.placeEntity(objectToPlace, placePosition, currentRotation, objectToPlace != UndergroundOutput)
	if result is UndergroundInput:
		undergroundsAvailable -= 1
		if twicePlacing:
			undergroundInputStoredNode2 = result.pathNode
			twicePlacing = false
		else:undergroundInputStoredNode = result.pathNode
		setCursor(UndergroundOutput)
	elif result is UndergroundOutput:
		result.pathNode = PathNode.new(result, result.position)
		if twicePlacing:
			result.pathNode.previousNode = undergroundInputStoredNode2
			undergroundInputStoredNode2.nextNode = result.pathNode
			result.pathNode.partialPath.joinAfter(undergroundInputStoredNode2)
			undergroundInputStoredNode2 = null
			twicePlacing = false
		else:
			result.pathNode.previousNode = undergroundInputStoredNode
			undergroundInputStoredNode.nextNode = result.pathNode
			result.pathNode.partialPath.joinAfter(undergroundInputStoredNode)
			undergroundInputStoredNode = null
		setCursor(Belt, true)
		result.ready()
	if result and result.pathNode.partialPath.getItemType() == Items.TYPES.PARTICLE and placePosition == cursorPosition:
		if result is UndergroundInput:
			setCursor(UndergroundInput, true)
			if undergroundsAvailable == 0: return result
			twicePlacing = true
		if result is UndergroundOutput:
			setCursor(UndergroundOutput)
			twicePlacing = true
		var requestPair:InputOutput.EntangledRequestPair = result.pathNode.partialPath.getRequestPair()
		var is2:bool
		if result.pathNode.partialPath.start.entity is Inputter:
			is2 = result.pathNode.partialPath.start.entity == requestPair.input2
		else:
			is2 = result.pathNode.partialPath.end.entity == requestPair.output2
		if is2: place(cursorPosition - requestPair.difference)
		else: place(cursorPosition + requestPair.difference)
	return result

func delete(deletePosition:Vector2i=cursorPosition) -> Entity:
	if paused: return
	if objectToPlace == UndergroundOutput:
		setCursor(UndergroundInput)
		return null
	hoverTime = 0
	var entityPresent: Entity = scene.getEntity(deletePosition)
	if entityPresent is InputOutput: return null
	var result = scene.deleteEntity(deletePosition)
	if result and result.pathNode.partialPath.getItemType() == Items.TYPES.PARTICLE and deletePosition == cursorPosition:
		var requestPair:InputOutput.EntangledRequestPair = result.pathNode.partialPath.getRequestPair()
		var is2:bool
		if result.pathNode.partialPath.start.entity is Inputter:
			is2 = result.pathNode.partialPath.start.entity == requestPair.input2
		else:
			is2 = result.pathNode.partialPath.end.entity == requestPair.output2
		if is2: delete(cursorPosition - requestPair.difference)
		else: delete(cursorPosition + requestPair.difference)
	return result

func tryZoomIn() -> void:
	if intendedCameraHeight > 1:
		intendedCameraHeight *= 0.8

func tryZoomOut() -> void:
	if intendedCameraHeight < 100:
		intendedCameraHeight *= 1.25
		upperCameraHeight *= 1.25

func randomUnlockedTile(itemType:Items.TYPES) -> Vector2i:
	@warning_ignore("integer_division") if itemType == Items.TYPES.ARTIFACT: return scene.spaces[scene.spaces.keys()[randi_range(0, len(scene.spaces) - 1)]].position + Vector2i(randi_range(0, Scene.SPACE_SIZE/2 - 1)*2, randi_range(0, Scene.SPACE_SIZE/2 - 1)*2)
	return scene.spaces[scene.spaces.keys()[randi_range(0, len(scene.spaces) - 1)]].position + Vector2i(randi_range(0, Scene.SPACE_SIZE - 1), randi_range(0, Scene.SPACE_SIZE - 1))

func isABadLocation(pos:Vector2i, type:Items.TYPES) -> bool:
	# should have space
	if !scene.getSpace(pos): return true
	if scene.getEntity(pos): return true
	# be out in the open
	var nearCount:int = 0
	for direction in U.V2I_DIRECTIONS:
		var entity:Entity = scene.getEntity(pos + direction)
		if entity:
			var theirType:Items.TYPES = entity.asPathNodeAt(pos + direction).partialPath.getItemType()
			if Items.isMetallic(type) and theirType == Items.TYPES.MAGNET: return true
			if type == Items.TYPES.MAGNET and Items.isMetallic(theirType): return true
			nearCount += 1
	if randi_range(0, 3) < nearCount: return true
	# not too close to edge
	for direction in U.V2I_DIRECTIONS:
		if !scene.getSpace(pos + direction*3) and randf() > 0.4: return true
	return false

func newInputOutputs() -> void:
	var type:Items.TYPES = itemTypesUnlocked[U.topHeavyRandI(len(itemTypesUnlocked))]
	ui.setItemTypeImage(Items.IMAGES[type])

	if type == Items.TYPES.PARTICLE:
		var requestPair:InputOutput.EntangledRequestPair = InputOutput.EntangledRequestPair.new(len(requestPairs), type)
		requestPairs.append(requestPair)

		var inputPos1:Vector2i
		var outputPos1:Vector2i
		var inputPos2:Vector2i
		var outputPos2:Vector2i
		while true:
			inputPos1 = randomUnlockedTile(type)
			outputPos1 = randomUnlockedTile(type)
			inputPos2 = randomUnlockedTile(Items.TYPES.ARTIFACT) + (inputPos1 % 2) # so that they are the same parity. fucked sorry
			outputPos2 = inputPos2 + outputPos1 - inputPos1
			if outputPos1.distance_squared_to(inputPos1) < 36 or inputPos1.distance_squared_to(outputPos2) < 9 or outputPos1.distance_squared_to(inputPos2) < 9: continue
			if isABadLocation(inputPos1, type) or isABadLocation(outputPos1, type) or isABadLocation(inputPos2, type) or isABadLocation(outputPos2, type): continue
			break
		requestPair.difference = inputPos2 - inputPos1
		var input:Inputter = scene.placeEntity(Inputter, inputPos1, U.ROTATIONS.UP)
		input.pathNode = PathNode.new(input, inputPos1)
		input.requestPair = requestPair
		requestPair.input = input
		var output:Outputter = scene.placeEntity(Outputter, outputPos1, U.ROTATIONS.UP)
		output.pathNode = PathNode.new(output, outputPos1)
		output.requestPair = requestPair
		requestPair.output = output
		var input2:Inputter = scene.placeEntity(Inputter, inputPos2, U.ROTATIONS.UP)
		input2.pathNode = PathNode.new(input2, inputPos2)
		input2.requestPair = requestPair
		requestPair.input2 = input2
		var output2:Outputter = scene.placeEntity(Outputter, outputPos2, U.ROTATIONS.UP)
		output2.pathNode = PathNode.new(output2, outputPos2)
		output2.requestPair = requestPair
		requestPair.output2 = output2
	else:
		var requestPair:InputOutput.RequestPair = InputOutput.RequestPair.new(len(requestPairs), type)
		requestPairs.append(requestPair)

		var inputPos:Vector2i = randomUnlockedTile(type)
		while isABadLocation(inputPos, type):
			inputPos = randomUnlockedTile(type)
		var input:Inputter = scene.placeEntity(Inputter, inputPos, U.ROTATIONS.UP)
		input.pathNode = PathNode.new(input, inputPos)
		input.requestPair = requestPair
		requestPair.input = input

		var outputPos:Vector2i = randomUnlockedTile(type)
		while outputPos.distance_squared_to(inputPos) < 36 or isABadLocation(outputPos, type):
			outputPos = randomUnlockedTile(type)
		var output:Outputter = scene.placeEntity(Outputter, outputPos, U.ROTATIONS.UP)
		output.pathNode = PathNode.new(output, outputPos)
		output.requestPair = requestPair
		requestPair.output = output

func pathComplete() -> void:
	for requestPair in requestPairs: if !requestPair.completed: return
	pathsThisRound += 1
	menu.consolePrint("Path {%s} complete" % len(requestPairs))
	if pathsThisRound == pathsPerRound:
		menu.consolePrint("Round %s complete" % rounds)
		paused = true
		checkIfUnlockItemType()
		ui.showEndRoundScreen()
		setCursor()
	else: newInputOutputs()
	ui.updatePathsCount()

func nextRound() -> void:
	rounds += 1
	timeLeft += 45
	if rounds == 2:
		get_tree().create_tween().tween_property($"ui/VBoxContainer", "position:y", 0, 1)
	pathsThisRound = 0
	ui.updateRoundsCount()
	ui.updatePathsCount()
	paused = false
	ui.hideEndRoundScreen()
	for _i in 4: randomNewSpace()
	newInputOutputs()
	setCursor()

func checkIfUnlockItemType():
	if rounds == 2: unlockItemType([Items.TYPES.FRIDGE, Items.TYPES.GYRO][randi_range(0,1)])
	elif rounds == 5: unlockItemType([Items.TYPES.MAGNET, Items.TYPES.CHEMICAL][randi_range(0,1)])
	elif rounds == 10: unlockItemType([Items.TYPES.ARTIFACT, Items.TYPES.PARTICLE][randi_range(0,1)])
	elif rounds % 5 == 0: unlockItemType(itemTypesLocked[randi_range(0, len(itemTypesLocked) - 1)])

func unlockItemType(type:Items.TYPES):
	unlockedItemTypeThisRound = true
	itemTypesLocked.remove_at(itemTypesLocked.find(type))
	itemTypesUnlocked.append(type)

func randomNewSpace() -> void:
	while true:
		var space:Space = scene.spaces[scene.spaces.keys()[randi_range(0, len(scene.spaces) - 1)]]
		var randomPosition = space.position + U.V2I_DIRECTIONS[randi_range(0,3)] * Scene.SPACE_SIZE
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

func setCursor(object:Variant=null, safe:=false) -> void:
	if object:
		if object == UndergroundInput and !isDebug and !undergroundsAvailable: return setCursor(Belt)

		if (object == UndergroundOutput) != (objectToPlace == UndergroundOutput): currentRotation = U.r180(currentRotation)
		if objectToPlace == UndergroundOutput and object != UndergroundOutput and !safe:
			if undergroundInputStoredNode: scene.deleteEntity(undergroundInputStoredNode.position)
			undergroundInputStoredNode = null
			if undergroundInputStoredNode2: scene.deleteEntity(undergroundInputStoredNode2.position)
			undergroundInputStoredNode2 = null
		objectToPlace = object
		match objectToPlace:
			Belt: cursor.mesh = preload("res://meshes/beltStraight.tres")
			UndergroundInput: cursor.mesh = preload("res://meshes/undergroundInput.tres")
			UndergroundOutput: cursor.mesh = preload("res://meshes/undergroundOutput.tres")
	cursor.visible = !paused
	cursor.rotation.y = U.rotToRad(currentRotation)

func screenspaceToWorldspace(pos:Vector2) -> Vector2i:
	return floor(U.xz(cameraPosition) + (pos / Vector2(get_viewport().size) - U.v2(0.5)) * effectiveScreenSize)

func worldspaceToScreenspace(pos:Vector2) -> Vector2:
	return ((Vector2(pos) - U.xz(cameraPosition)) / effectiveScreenSize + U.v2(0.5)) * Vector2(get_viewport().size)

func lose() -> void:
	trulyPaused = true
	paused = true
	setCursor()
	var tween = create_tween()
	tween.tween_interval(1)
	tween.tween_callback(func(): menu.overlay.mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP)
	tween.tween_property(menu.overlay, "modulate:a", 0.5, 0.5)
	tween.tween_interval(1)
	if !menu.paused: tween.tween_callback(menu.togglePause)
	menu.consoleError("""FATAL: Timeout error
				at %s rounds
				at %s connections
				at game.gd""" % [rounds, len(requestPairs)-1])
	menu.consolePrint("Select game.gd to try again")

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
