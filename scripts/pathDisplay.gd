extends Node2D
class_name PathDisplay

const SIXTEEN_OVER_ROOT_2:float = 11.313708499

@onready var game:Game = $".."
var hovered:PathNode

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if !hovered: return
	for requestPair in hovered.partialPath.getRequestPairs():
		for path in requestPair.getPaths():
			for node in path.enumerate():
				#if !node: continue # whatever
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
