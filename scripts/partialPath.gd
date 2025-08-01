extends RefCounted
class_name PartialPath

var game:Game

var id:int
var toInput:PathNode
var toOutput:PathNode
var itemType:Items.TYPES
var start:PathNode

func _init(_game:Game, _start:PathNode) -> void:
    game = _game
    id = game.partialPathIdIncr
    game.partialPathIdIncr += 1
    start = _start

func update() -> void:
    var head:PathNode = start
    head.entity.loadVisuals()
    while head.nextNode:
        head = head.nextNode
        head.entity.loadVisuals()

func splitAt(pathNode:PathNode) -> void:
    var head:PathNode = pathNode
    if head.nextNode:
        var forwards:PartialPath = PartialPath.new(game, head.nextNode)
        while head.nextNode:
            head = head.nextNode
            head.partialPath = forwards
        forwards.update()
    pathNode.partialPath.update()

func joinAfter(pathNode:PathNode) -> void:
    var head:PathNode = pathNode
    while head.nextNode:
        head = head.nextNode
        head.partialPath = pathNode.partialPath
    pathNode.partialPath.update()

func _to_string() -> String: return str(id)
