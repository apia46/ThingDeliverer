extends PanelContainer
class_name MainMenu

@onready var menu = get_node("/root/menu")

func _startGame() -> void:
	menu.startGame()
