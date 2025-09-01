extends Node2D
class_name PathDisplay

@onready var game:Game = $".."
var hovered:PathNode
var dottedLinesUsed:int
@onready var dottedLines:Array[Line2D] = [$"../dottedLines/dottedLine", $"../dottedLines/dottedLine2", $"../dottedLines/dottedLine3", $"../dottedLines/dottedLine4", $"../dottedLines/dottedLine5", $"../dottedLines/dottedLine6", $"../dottedLines/dottedLine7", $"../dottedLines/dottedLine8"]

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if !hovered: return

	dottedLinesUsed = 0
	for dottedLine in dottedLines:
		dottedLine.visible = false
	if hovered.partialPath.mispairedError():
		enumeratePath(hovered.partialPath, false)
		for pair in hovered.partialPath.getRequestPairs():
			drawDottedLine(
				game.worldspaceToScreenspace(Vector2(pair.input.position)+U.v2(0.5)),
				game.worldspaceToScreenspace(Vector2(pair.output.position)+U.v2(0.5)),
				PartialPath.STATES_COLOR[1], PartialPath.STATES_COLOR[2]
			)
			drawInput(pair.input.pathNode.partialPath, game.worldspaceToScreenspace(Vector2(pair.input.position)+U.v2(0.5)))
			drawOutput(pair.output.pathNode.partialPath, game.worldspaceToScreenspace(Vector2(pair.output.position)+U.v2(0.5)))
			if pair is InputOutput.EntangledRequestPair:
				drawDottedLine(
					game.worldspaceToScreenspace(Vector2(pair.input2.position)+U.v2(0.5)),
					game.worldspaceToScreenspace(Vector2(pair.output2.position)+U.v2(0.5)),
					PartialPath.STATES_COLOR[1], PartialPath.STATES_COLOR[2]
				)
	else:
		var requestPair:InputOutput.RequestPair = hovered.partialPath.getRequestPair()
		if !requestPair: return
		if !requestPair.completed and !(requestPair is InputOutput.EntangledRequestPair and !requestPair.completed1):
			drawDottedLine(
				game.worldspaceToScreenspace(Vector2(requestPair.input.pathNode.partialPath.end.position)+U.v2(0.5)),
				game.worldspaceToScreenspace(Vector2(requestPair.output.pathNode.partialPath.start.position)+U.v2(0.5)),
				PartialPath.STATES_COLOR[1], PartialPath.STATES_COLOR[2]
			)
		if requestPair is InputOutput.EntangledRequestPair and !requestPair.completed2:
			drawDottedLine(
				game.worldspaceToScreenspace(Vector2(requestPair.input2.pathNode.partialPath.end.position)+U.v2(0.5)),
				game.worldspaceToScreenspace(Vector2(requestPair.output2.pathNode.partialPath.start.position)+U.v2(0.5)),
				PartialPath.STATES_COLOR[1], PartialPath.STATES_COLOR[2]
			)
		for path in requestPair.getPaths():
			enumeratePath(path)

func enumeratePath(path:PartialPath, drawInputOutputs:bool=true):
	for node in path.enumerate():
		if node == path.end or node == path.start or (node.entity is Belt and node.entity.previousDirection != U.ROTATIONS.DOWN):
			draw_circle(
				game.worldspaceToScreenspace(Vector2(node.position)+U.v2(0.5)), 4,
				path.getColor(), true
			)
		if !node.nextNode: break
		draw_line(
			game.worldspaceToScreenspace(Vector2(node.position) + U.v2(0.5)),
			game.worldspaceToScreenspace(Vector2(node.nextNode.position) + U.v2(0.5)),
			path.getColor(), 8
		)
	if drawInputOutputs and path.start.entity is Inputter: drawInput(path, game.worldspaceToScreenspace(Vector2(path.start.position)+U.v2(0.5)))
	if drawInputOutputs and path.end.entity is Outputter: drawOutput(path, game.worldspaceToScreenspace(Vector2(path.end.position)+U.v2(0.5)))

func drawInput(path:PartialPath, center:Vector2):
	draw_polygon(
		[center+Vector2(32,0), center+Vector2(0,32),
		center+Vector2(-32,0), center+Vector2(0,-32), center+Vector2(32,0)],
		[Color(0x2e2f38ff)]
	)
	draw_polyline(
		[center+Vector2(32,0), center+Vector2(0,32),
		center+Vector2(-32,0), center+Vector2(0,-32), center+Vector2(32,0)],
		path.getColor(), 8
	)
	draw_texture_rect(
		Items.IMAGES[path.start.entity.requestPair.itemType],
		Rect2(
			center - U.v2(16/sqrt(2)),
			U.v2(16*sqrt(2))
		), false
	)

func drawOutput(path:PartialPath, center:Vector2):
	draw_rect(
		Rect2(
			center - U.v2(32/sqrt(2)),
			U.v2(32*sqrt(2))
		), Color(0x2e2f38ff)
	)
	draw_rect(
		Rect2(
			center - U.v2(32/sqrt(2)),
			U.v2(32*sqrt(2))
		), path.getColor(), false, 8
	)
	draw_texture_rect(
		Items.IMAGES[path.end.entity.requestPair.itemType],
		Rect2(
			center - U.v2(16/sqrt(2)),
			U.v2(16*sqrt(2))
		), false
	)

func drawDottedLine(start:Vector2, end:Vector2, startColor:Color, endColor:Color):
	var dottedLine:Line2D = dottedLines[dottedLinesUsed]
	dottedLine.visible = true
	dottedLine.points = [start, end]
	dottedLine.gradient.colors = PackedColorArray([startColor, endColor])
	dottedLinesUsed += 1
