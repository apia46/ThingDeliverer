extends Node3D
class_name Game

const FLOOR_MATERIAL:ShaderMaterial = preload("res://resources/floor.tres")
const CAMERA_MOVE_SPEED:float = 2

@onready var menu:Menu = $"/root/menu"
@onready var scene:Scene = $"scene"
@onready var ui = $"ui"
@onready var cursor = $"ui/SubViewportContainer/cursorViewport/cursor"
@onready var hover:H = $"hover"
@onready var pathDisplay:PathDisplay = $"pathDisplay"

var intendedCameraHeight:float = 20
var upperCameraHeight: float = 20
var effectiveScreenSize:Vector2 = Vector2(54.56548, 30.69308)
var cursorPosition:Vector2i

var cycle:float = 0
var timeLeft:float = 0
var timeSinceStart:float = 0

var objectToPlace:Object = Belt
var undergroundInputStoredNode:PathNode
var undergroundInputStoredNode2:PathNode
var twicePlacing:bool = false
var undergroundsAvailable = 0:
	set(value):
		undergroundsAvailable = value
		ui.updateUndergroundsCount()
var throughpathsAvailable = 0:
	set(value):
		throughpathsAvailable = value
		ui.updateThroughpathsCount()

var currentRotation:U.ROTATIONS = U.ROTATIONS.UP:
	set(value):
		currentRotation = value
		@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.ROTATION: tutorialState += 1
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

const HOVER_INSPEED:float = 5
const HOVER_OUTSPEED:float = 5
var hoverPosition:Vector2i = Vector2i(0, 0)
var hoverTime:float = 0

var timerMultiplier:float = 1.5

var timerExists:bool
var hardMode:bool
var spaceGenType:SpaceGenType = SpaceGenType.CITY
enum SpaceGenType { RANDOM_WALK, BULLSHIT, CITY }

var reviewing:bool = false

enum TutorialStates { CAMERA_MOVE, CAMERA_ZOOM, PLACEMENT, ROTATION, SOLVE_PATH, FINAL, CHOOSE_ENTITY, UNDERPATHS, THROUGHPATHS, NONE }
var tutorialState:TutorialStates = TutorialStates.NONE:
	set(value):
		tutorialState = value
		match value:
			TutorialStates.CAMERA_MOVE:
				ui.showTutorial("Use [MMB] drag to move the camera.\nAlternatively, use [WASD] to move the camera.")
			TutorialStates.CAMERA_ZOOM:
				ui.showTutorial("Use [MMB] scroll to zoom the camera in/out.\nAlternatively, use [SPACE] to toggle between two preset camera zoom levels.")
			TutorialStates.PLACEMENT:
				ui.showTutorial("Place entities with [LMB].\nDelete entities with [RMB].")
			TutorialStates.ROTATION:
				ui.showTutorial("Use [Q] and [E] or [Shift] + [WASD] to rotate the entity held in cursor.")
			TutorialStates.SOLVE_PATH:
				ui.showTutorial("Connect the input <+> to the output [x] using belts.")
			TutorialStates.FINAL:
				ui.showTutorial("These controls can be found in the README page.\nYou can press [Esc] to bring up the menu.\nHave fun!")
			TutorialStates.CHOOSE_ENTITY:
				ui.showTutorial("Click on the icon or use [123] to change entity to place.")
			TutorialStates.UNDERPATHS:
				ui.showTutorial("Underpaths can create a bypass to up to 4 tiles away.\n[LMB] to place the input, and then [LMB] again to place the output. [RMB] to cancel.")
			TutorialStates.THROUGHPATHS:
				ui.showTutorial("Throughpaths can be used to path belts through eachother.\nTwo throughpaths placed adjacently will not connect with eachother.")

func _ready() -> void:
	scene.newSpace(U.v2(0))
	setCursor(Belt)
	menu.consoleSet("Game Started")

func settings(_timerExists:bool, _hardMode:bool, _mapType:SpaceGenType) -> void:
	timerExists = _timerExists
	hardMode = _hardMode
	spaceGenType = _mapType
	for _i in 15: randomNewSpace()
	newInputOutputs()
	if hardMode:
		pathsPerRound = 8
		ui.updatePathsCount()
		timerMultiplier = 1
	if menu.config.showTutorial: tutorialState = TutorialStates.CAMERA_MOVE
	

func _process(delta:float) -> void:
	var previousCursorPosition:Vector2i = cursorPosition
	if !paused and !Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_A):
			cameraPosition.x -= delta * CAMERA_MOVE_SPEED * intendedCameraHeight
			@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.CAMERA_MOVE: tutorialState += 1
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): heldClick(previousCursorPosition)
		if Input.is_key_pressed(KEY_W):
			cameraPosition.z -= delta * CAMERA_MOVE_SPEED * intendedCameraHeight
			@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.CAMERA_MOVE: tutorialState += 1
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): heldClick(previousCursorPosition)
		if Input.is_key_pressed(KEY_S):
			cameraPosition.z += delta * CAMERA_MOVE_SPEED * intendedCameraHeight
			@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.CAMERA_MOVE: tutorialState += 1
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): heldClick(previousCursorPosition)
		if Input.is_key_pressed(KEY_D):
			cameraPosition.x += delta * CAMERA_MOVE_SPEED * intendedCameraHeight
			@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.CAMERA_MOVE: tutorialState += 1
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): heldClick(previousCursorPosition)
	
	cameraPosition.y += (intendedCameraHeight - cameraPosition.y) * delta * 10
	var aspectRatio = float(get_viewport().size.x) / get_viewport().size.y
	effectiveScreenSize = Vector2(cameraPosition.y * 1.534653976 * aspectRatio, cameraPosition.y * 1.534653976) # 2y tan 37.5
	if abs(intendedCameraHeight / cameraPosition.y - 1) < 0.001 and abs(intendedCameraHeight / cameraPosition.y - 1) > 0.000001:
		cameraPosition.y = intendedCameraHeight
		upperCameraHeight = intendedCameraHeight
	
	FLOOR_MATERIAL.set_shader_parameter("interpolation", clamp(cameraPosition.y * 0.05 - 0.75, 0, 1))
	
	setCursorPosition()
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

	if !trulyPaused:
		if !paused: cycle += 4 * delta
		else: cycle += delta
	if cycle >= Items.SPACES_PER_ITEM:
		cycle -= Items.SPACES_PER_ITEM
	scene.items.updateDisplays()
	
	if !paused and rounds > 1 and timerExists and !reviewing:
		timeLeft -= delta
		if timeLeft < 0: lose()
	ui.updateTimer()

	timeSinceStart += delta

	var hovered:Entity = scene.getEntity(cursorPosition)
	if hovered and !paused:
		hoverPosition = cursorPosition
		hover.setHover(hovered)
		if hovered: pathDisplay.hovered = hovered.asPathNodeAt(cursorPosition)
		hoverTime += delta * HOVER_INSPEED
	else:
		pathDisplay.hovered = null
		hoverTime -= delta * HOVER_OUTSPEED
	hoverTime = clampf(hoverTime, 0, 1)
	hover.modulate.a = int(hovered and !paused)
	hover.position.x = get_viewport().size.x - hover.size.x - 20
	hover.position.y = 20
	pathDisplay.modulate.a = (hoverTime - 0.6) * 3
	$"dottedLines".modulate.a = (hoverTime - 0.6) * 3
	
	if objectToPlace == Throughpath: currentRotation = U.ROTATIONS.UP

func setCursorPosition(placing:bool=false) -> void:
	if objectToPlace == Throughpath and placing:
		cursorPosition = floor(Vector2(0.5, -0.5) + U.xz(cameraPosition) + (get_viewport().get_mouse_position() / Vector2(get_viewport().size) - U.v2(0.5)) * effectiveScreenSize)
	else: cursorPosition = screenspaceToWorldspace(get_viewport().get_mouse_position())

func heldClick(previousCursorPosition:Vector2i) -> void:
	if reviewing: return
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
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_R and trulyPaused: review()
	if paused: return
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.CAMERA_MOVE: tutorialState += 1
			cameraPosition -= U.fxz(event.relative) * intendedCameraHeight * 0.00237
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			setCursorPosition()
			heldClick(screenspaceToWorldspace(event.position - event.relative))
	elif event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP: tryZoomIn()
				MOUSE_BUTTON_WHEEL_DOWN: tryZoomOut()
				MOUSE_BUTTON_LEFT:
					if objectToPlace != UndergroundOutput: setCursorPosition(true)
					dragStartPos = cursorPosition
					place()
				MOUSE_BUTTON_RIGHT:
					setCursorPosition()
					delete()
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
				KEY_K: pathComplete(true)
				KEY_SPACE:
					@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.CAMERA_ZOOM: tutorialState += 1
					if intendedCameraHeight > 50: intendedCameraHeight = 20
					else: intendedCameraHeight = 76.2939453125; upperCameraHeight = 76.2939453125

func restartDragFromHere():
	hoverTime = 0
	if U.isKnown(currentDragX):
		dragStartPos = screenspaceToWorldspace(get_viewport().get_mouse_position())
		currentDragX = U.bool3not(currentDragX)

func cantPlace(placePosition) -> bool:
	var entityPresent: Entity = scene.getEntity(placePosition)
	if entityPresent is InputOutput: return true
	if !scene.getSpace(placePosition): return true
	if objectToPlace == UndergroundOutput and entityPresent is UndergroundInput: return true
	if objectToPlace == UndergroundInput and undergroundsAvailable == 0 and !isDebug: return true
	if objectToPlace ==  Throughpath and throughpathsAvailable == 0 and !isDebug: return true
	return false

func place(placePosition:Vector2i=cursorPosition) -> Entity:
	if paused or reviewing: return
	@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.PLACEMENT: tutorialState += 1
	hoverTime = 0
	if cantPlace(placePosition): return null
	if objectToPlace == Throughpath:
		if cantPlace(placePosition): return null
		if cantPlace(placePosition + Vector2i(-1, 0)): return null
		if cantPlace(placePosition + Vector2i(-1, 1)): return null
		if cantPlace(placePosition + Vector2i(0, 1)): return null
		throughpathsAvailable -= 1
		scene.deleteEntity(placePosition + Vector2i(-1, 0))
		scene.deleteEntity(placePosition + Vector2i(-1, 1))
		scene.deleteEntity(placePosition + Vector2i(0, 1))
		@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.THROUGHPATHS: ui.hideTutorial(1.5)
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
		@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.UNDERPATHS: ui.hideTutorial(1.5)
	if result and !(result is Throughpath or result is ThroughpathReference) and result.pathNode.partialPath.getItemType() == Items.TYPES.PARTICLE and placePosition == cursorPosition:
		if result is UndergroundInput:
			setCursor(UndergroundInput, true)
			if undergroundsAvailable == 0: return result
			twicePlacing = true
		if result is UndergroundOutput:
			if !undergroundInputStoredNode2: return result
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
	if paused or reviewing: return
	if objectToPlace == UndergroundOutput:
		setCursor(UndergroundInput)
		return null
	hoverTime = 0
	var entityPresent: Entity = scene.getEntity(deletePosition)
	if entityPresent is InputOutput: return null
	var result = scene.deleteEntity(deletePosition)
	if result and !(result is Throughpath or result is ThroughpathReference) and result.pathNode.partialPath.getItemType() == Items.TYPES.PARTICLE and deletePosition == cursorPosition:
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
	@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.CAMERA_ZOOM: tutorialState += 1
	if intendedCameraHeight > 1:
		intendedCameraHeight *= 0.8

func tryZoomOut() -> void:
	@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.CAMERA_ZOOM: tutorialState += 1
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
		while outputPos.distance_squared_to(inputPos) < 36 or (type in [Items.TYPES.CHEMICAL, Items.TYPES.GYRO] and outputPos.distance_squared_to(inputPos) > 256) or isABadLocation(outputPos, type):
			outputPos = randomUnlockedTile(type)
		var output:Outputter = scene.placeEntity(Outputter, outputPos, U.ROTATIONS.UP)
		output.pathNode = PathNode.new(output, outputPos)
		output.requestPair = requestPair
		requestPair.output = output

func pathComplete(forced:=false) -> void:
	if !forced:
		for requestPair in requestPairs:
			if !requestPair.completed: return
	pathsThisRound += 1
	@warning_ignore("int_as_enum_without_cast") if tutorialState == TutorialStates.SOLVE_PATH: tutorialState += 1
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
	timeLeft += 60 * timerMultiplier
	if rounds == 2 and timerExists:
		get_tree().create_tween().tween_property($"ui/VBoxContainer", "position:y", 0, 1)
	pathsThisRound = 0
	ui.updateRoundsCount()
	ui.updatePathsCount()
	paused = false
	ui.hideEndRoundScreen()
	for _i in 5: randomNewSpace()
	newInputOutputs()
	setCursor()

func checkIfUnlockItemType():
	if rounds == 2: unlockItemType([Items.TYPES.FRIDGE, Items.TYPES.GYRO][randi_range(0,1)])
	elif rounds == 4: unlockItemType([Items.TYPES.MAGNET, Items.TYPES.CHEMICAL][randi_range(0,1)])
	elif rounds == 7: unlockItemType([Items.TYPES.ARTIFACT, Items.TYPES.PARTICLE][randi_range(0,1)])
	elif rounds > 9 and rounds % 5 == 0 and len(itemTypesLocked) > 0: unlockItemType(itemTypesLocked[randi_range(0, len(itemTypesLocked) - 1)])

func unlockItemType(type:Items.TYPES):
	unlockedItemTypeThisRound = true
	itemTypesLocked.remove_at(itemTypesLocked.find(type))
	itemTypesUnlocked.append(type)

func randomNewSpace() -> void:
	match spaceGenType:
		SpaceGenType.BULLSHIT:
			while true:
				var space:Space = scene.spaces[scene.spaces.keys()[randi_range(0, len(scene.spaces) - 1)]]
				var randomPosition = space.position + U.V2I_DIRECTIONS[randi_range(0,3)] * Scene.SPACE_SIZE
				if scene.newSpace(randomPosition): return
		SpaceGenType.RANDOM_WALK:
			var randomWalkPos = Vector2i(0,0)
			while true:
				if randi_range(0,1): randomWalkPos.x += 1 if randi_range(0,1) else -1
				else: randomWalkPos.y += 1 if randi_range(0,1) else -1
				if scene.newSpace(randomWalkPos*Scene.SPACE_SIZE): return
		SpaceGenType.CITY:
			var randomWalkPos = Vector2i(0,0)
			while true:
				var direction:Vector2i
				if (randi_range(0,1) or randomWalkPos.x%2!=0) and randomWalkPos.y%2==0: direction = Vector2i((1 if randi_range(0,1) else -1), 0)
				else: direction = Vector2i(0, (1 if randi_range(0,1) else -1))
				randomWalkPos += direction
				if !scene.getSpace(randomWalkPos*Scene.SPACE_SIZE):
					var rot:U.ROTATIONS = U.v2itorot(direction)
					if scene.getSpace((randomWalkPos+direction)*Scene.SPACE_SIZE):
						if randi_range(0,max(10,1000-randomWalkPos.length_squared())): continue
					elif scene.getSpace((randomWalkPos+U.rotate(Vector2i(1, -1), rot))*Scene.SPACE_SIZE)\
					or scene.getSpace((randomWalkPos+U.rotate(Vector2i(-1, -1), rot))*Scene.SPACE_SIZE):
						if randi_range(0,max(10,1000-randomWalkPos.length_squared())): randomWalkPos += direction
					scene.newSpace(randomWalkPos*Scene.SPACE_SIZE)
					return

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
		if object == Throughpath and !isDebug and !throughpathsAvailable: return setCursor(Belt)

		@warning_ignore("int_as_enum_without_cast") if object == UndergroundInput and tutorialState == TutorialStates.CHOOSE_ENTITY: tutorialState += 1

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
			Throughpath: cursor.mesh = preload("res://meshes/throughpath.tres")
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
	menu.consolePrint("Press [R] to review")

func review():
	if reviewing: return
	paused = false
	var tween = create_tween()
	tween.tween_property(menu.overlay, "modulate:a", 0, 0.5)
	tween.tween_callback(func(): menu.overlay.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE)
	reviewing = true
	timeLeft = 0
	ui.updateTimer()
	ui.hotbar.visible = false

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
