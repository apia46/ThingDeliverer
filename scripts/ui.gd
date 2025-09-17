extends Control

@onready var game = get_node("..")

@onready var hotbar = %hotbar
@onready var tutorial = %tutorial
@onready var tutorialText = %tutorialText
var tutorialTween:float = 1

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_1: belt()
			KEY_2: underground()
			KEY_3: throughpath()

func _process(_delta):
	tutorial.position = size - tutorial.size - Vector2(16, 16)
	tutorial.position.x += (tutorial.size.x+32)*tutorialTween

func showTutorial(text):
	if tutorialTween == 1:
		%tutorialProgress.value = 0
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tutorialText.text = text
		tutorial.size = Vector2(0,0)
		tween.tween_property(self, "tutorialTween", 0, 0.5)
		if game.tutorialState in [game.TutorialStates.FINAL, game.TutorialStates.FINAL_2]:
			tween.tween_callback(hideTutorial)
	else:
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_interval(1.5)
		tween.tween_property(self, "tutorialTween", 1, 0.5)
		tween.tween_interval(0.5)
		tween.tween_callback(showTutorial.bind(text))
		var tween2 = create_tween()
		tween2.tween_property(%tutorialProgress, "value", 1, 1.5)

func hideTutorial(time:float=5):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(time)
	tween.tween_property(self, "tutorialTween", 1, 0.5)
	var tween2 = create_tween()
	tween2.tween_property(%tutorialProgress, "value", 1, time)

func belt() -> void: game.setCursor(Belt)
func underground() -> void: game.setCursor(UndergroundInput)
func throughpath() -> void: game.setCursor(Throughpath)

func updateTimer() -> void:
	%timerBar.value = game.timeLeft
	%timer.text = U.timeToText(game.timeLeft)

func updateUndergroundsCount() -> void:
	%undergroundsCount.text = str(game.undergroundsAvailable)
	if game.undergroundsAvailable == 0: %undergroundsCount.get_theme_stylebox("normal").border_color = Color("#aaacc4")
	else: %undergroundsCount.get_theme_stylebox("normal").border_color = Color("#ffd800")

func updateThroughpathsCount() -> void:
	%throughpathsCount.text = str(game.throughpathsAvailable)
	if game.throughpathsAvailable == 0: %throughpathsCount.get_theme_stylebox("normal").border_color = Color("#aaacc4")
	else: %throughpathsCount.get_theme_stylebox("normal").border_color = Color("#ffd800")

func updateRoundsCount() -> void: %roundsCount.text = "Round " + str(game.rounds)

func updatePathsCount() -> void: %pathsCount.text = str(game.pathsThisRound) + "/" + str(game.pathsPerRound)

func showEndRoundScreen() -> void:
	%endRoundScreen.loadNext()
	%endRoundScreen.visible = true
func hideEndRoundScreen() -> void: %endRoundScreen.visible = false

func setItemTypeImage(image:CompressedTexture2D) -> void:
	%itemType.texture = image
