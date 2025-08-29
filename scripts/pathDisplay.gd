extends Node2D
class_name PathDisplay

const SIXTEEN_OVER_ROOT_2:float = 11.313708499

@onready var game:Game = $".."
var hovered:PathNode
var dottedLinesUsed:int
@onready var dottedLines:Array[Line2D] = [$"dottedLine", $"dottedLine2", $"dottedLine3", $"dottedLine4", $"dottedLine5", $"dottedLine6", $"dottedLine7", $"dottedLine8"]

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if !hovered: return

	dottedLinesUsed = 0
	for dottedLine in dottedLines:
		dottedLine.visible = false
	if hovered.partialPath.mispairedError():
		for pair in hovered.partialPath.getRequestPairs():
			drawDottedLine(
				game.worldspaceToScreenspace(Vector2(pair.input.position)+U.v2(0.5)),
				game.worldspaceToScreenspace(Vector2(pair.output.position)+U.v2(0.5)),
				PartialPath.STATES_COLOR[1], PartialPath.STATES_COLOR[2]
			)
			if pair is InputOutput.EntangledRequestPair:
				drawDottedLine(
					game.worldspaceToScreenspace(Vector2(pair.input2.position)+U.v2(0.5)),
					game.worldspaceToScreenspace(Vector2(pair.output2.position)+U.v2(0.5)),
					PartialPath.STATES_COLOR[1], PartialPath.STATES_COLOR[2]
				)
		enumeratePath(hovered.partialPath)
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

func enumeratePath(path:PartialPath):
	for node in path.enumerate():
		if node == path.end or node == path.start:
			draw_circle(
				game.worldspaceToScreenspace(Vector2(node.position)+U.v2(0.5)), 4,
				path.getColor(), true
			)
			if node.entity is Inputter:
				var center:Vector2 = game.worldspaceToScreenspace(Vector2(node.position)+U.v2(0.5))
				draw_polyline(
					[center+Vector2(16,0), center+Vector2(0,16),
					center+Vector2(-16,0), center+Vector2(0,-16), center+Vector2(16,0)],
					path.getColor(), 8
				)
			elif node.entity is Outputter:
				draw_rect(
					Rect2(
						game.worldspaceToScreenspace(Vector2(node.position)+U.v2(0.5))-U.v2(SIXTEEN_OVER_ROOT_2),
						U.v2(SIXTEEN_OVER_ROOT_2*2)
					), path.getColor(), false, 8
				)
		if !node.nextNode: break
		draw_line(
			game.worldspaceToScreenspace(Vector2(node.position) + U.v2(0.5)),
			game.worldspaceToScreenspace(Vector2(node.nextNode.position) + U.v2(0.5)),
			path.getColor(), 8
		)

func drawDottedLine(start:Vector2, end:Vector2, startColor:Color, endColor:Color):
	var dottedLine:Line2D = dottedLines[dottedLinesUsed]
	dottedLine.visible = true
	dottedLine.points = [start, end]
	dottedLine.gradient.colors = PackedColorArray([startColor, endColor])
	dottedLinesUsed += 1
