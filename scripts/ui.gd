extends Control

@onready var game = get_node("/root/game");

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_1: belt()
			KEY_2: underground()

func belt() -> void: game.setCursor(Belt)
func underground() -> void: game.setCursor(UndergroundInput)

func updateTimer(time:float) -> void:
	%timerBar.value = time
	%timer.text = U.timeToText(time)

func updateUndergroundsCount(amount:int) -> void:
	%undergroundsCount.text = str(amount)
	if amount == 0: %undergroundsCount.get_theme_stylebox("normal").border_color = Color("#aaacc4")
	else: %undergroundsCount.get_theme_stylebox("normal").border_color = Color("#ffd800")

func updateRoundsCount(amount:int) -> void:
	%roundsCount.text = "Round " + str(amount)

func updatePathsCount(amount:int, total:int) -> void:
	%pathsCount.text = str(amount) + "/" + str(total)

func showEndRoundScreen() -> void:
	%endRoundScreen.visible = true
