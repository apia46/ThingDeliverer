extends Control

@onready var menu = get_node("/root/menu")

func _yes():
	menu.confirmEndRun()
	menu._chooseFile(1)
	menu.mainMenuButton.button_pressed = true
	visible = false

func _no():
	visible = false
