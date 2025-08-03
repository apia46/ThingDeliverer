extends Control

@onready var game = get_node("/root/game")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_1: belt()
			KEY_2: underground()

func belt() -> void: game.setCursor(Belt)
func underground() -> void: game.setCursor(UndergroundInput)

func updateTimer() -> void:
	%timerBar.value = game.timeLeft
	%timer.text = U.timeToText(game.timeLeft)

func updateUndergroundsCount() -> void:
	%undergroundsCount.text = str(game.undergroundsAvailable)
	if game.undergroundsAvailable == 0: %undergroundsCount.get_theme_stylebox("normal").border_color = Color("#aaacc4")
	else: %undergroundsCount.get_theme_stylebox("normal").border_color = Color("#ffd800")

func updateRoundsCount() -> void: %roundsCount.text = "Round " + str(game.rounds)

func updatePathsCount() -> void: %pathsCount.text = str(game.pathsThisRound) + "/" + str(game.pathsPerRound)

func showEndRoundScreen() -> void:
	%endRoundScreen.loadNext()
	%endRoundScreen.visible = true
func hideEndRoundScreen() -> void: %endRoundScreen.visible = false
