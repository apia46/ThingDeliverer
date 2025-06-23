extends Control

@onready var game = get_node("/root/game");

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_1: belt()
			KEY_2: underground()

func belt() -> void: game.setCursor(Belt)

func underground() -> void: game.setCursor(UndergroundInput)
