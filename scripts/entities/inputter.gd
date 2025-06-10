extends InputOutput
class_name Inputter

var itemDisplay:Items.Display

func loadVisuals():
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/input.tscn").instantiate()
	
	if pathPoint and pathPoint.complete and !itemDisplay: itemDisplay = chunk.scene.items.addDisplay(Items.TYPES.BOX, positionAbsolute(), rotation)
	elif itemDisplay: itemDisplay = chunk.scene.items.removeDisplay(itemDisplay)
	super()
