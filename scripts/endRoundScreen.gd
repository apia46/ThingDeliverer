extends Panel

const FLAVOR_TEXT:Array[String] = [
	"Minor bug fixes",
	"Fixed rare crash involving looping a path back on itself",
	"Fixed rare crash upon loading the game", # noobogonis
	"Fixed rare crash involving a dog... inside an hourglass... hourglass dog",
	"Fixed Windows version from working",
	"Herobrine removed",
	"This version is actually stable now I swear",
	"Fixed bug where mechanic would work as intended",
	"Don't look at the code please",
	"Fixed bug where you could gain the down-diagonal dash 1.2x speedboost multiple times if the dash ends before touching the floor",
	"Removed belts\n • Readded belts",
	"Added this line to changelog",
	"The game is playable now",
	"Finally fixed that thing with the thing",
	"Ported codebase back to Rust",
	"Ported codebase back from Rust",
	"Several breaking changes but I forgot what they were",
	"Fixed lag issue by removing framerate display",
	"Codebase has been removed. Project now runs entirely on hopes and dreams",
	"Fixed bug where game would break after the year 2000",
	"Fixed bug where game would break after the year 2038",
	# <aster>
	"I don't know what I did but it works now",
	"Fixed a crash that happened on AMD GPUs that have been left out in the sun for (exactly) 3 hours 4 minutes and 11 seconds",
	"Refactored the entire codebase",
	"Removed defunct library",
	"Added defunct library",
	"Added rasterization to all sounds",
	"Fixed vysnc issues (framerate removed)",
	"Removed redundant features",
	"Added useless features",
	"Added 143 TBs of textures",
	"Removed support for Windows 95",
	"Reintroduced several issues from prior versions",
	"Removed at least one feature accidentally",
	"Removed support for Hannah Montana Linux",
	"Switched rendering pipeline to DirectX3",
	"New feature: you can now cook eggs on your computer",
	"Fixed the sun leaking",
	"Major bug introductions",
	"Temporary hotfix for crashes",
	"Hotfix for stuttering",
	"New and exciting behaviors",
	"Fun and whimsy have been optimized out",
	"New and improved lifelike models",
	"Rebranded the entire project",
	"Can now run Doom",
	"UTF-8 encoded all strings",
	"Fixed bug where game was fun",
	"Added microtransactions",
	"Removed microtransactions after community backlash",
	"Removed rendering pipeline, please use command line",
	"Maybe this will fix it",
	"I got someone else to fix it for me",
	"Removed stolen assets, oops",
	"I think it's sentient now",
	"Ported game to console",
	"Ported game to mobile",
	"Ported game to run inside Doom",
	"Game is now turing complete",
	"Broke all mods again",
	"Spent 3 months on a feature nobody will notice",
	"Added multithreading",
	"Removed multithreading",
	"Fixed multithreading",
	"Nobody reads these anyway",
	"Several internal ID changes",
	"Added bugs. They have six legs",
	"Fixed an issue that was bugging nobody but me",
	"Removed a feature I liked but nobody else did",
	"Next update will take awhile",
	"Fixed a bug where game broke on secondary monitors",
	"Fixed some off-center UI elements",
	"Fixed a crash on Nvidia GPUs",
	"Fixed a bug on Intel CPUs",
	"Removed the moonlit library",
	"Reworked progression entirely",
	# </aster>
	"Added secret", # vangare
	"Removed hallucination, but what was even there..?",
	"Temporarily disabled strong nuclear force (thanks, J)",
	"Removed intrusive thoughtform",
	"Fixed bug where opening the menu didn't pause the game",
	"Removed the OLD_DATA",
	"\n   -Fixed changelog formatting", # blizzle
	"Shuffled keybinds around",
	"Removed J's „special code“", # omnicrumb
	"Reverted previous build's changes back to original. As the original and current state is unintentional behaviour, we'll likely address this again in a future build, however it was clear that the changes we made were not acceptable to the existing playerbase", # blizzle
	"Added adders", # vangare
	"Removed removers",
	"Changed the build number",
	"Removed unused coconut graphic (why was this here?)", # dudemine
	"Removed easter egg after it got datamined immediately. It's impossible to have secrets nowadays",
	"Removed unit tests that were erroneously failing",
	"Temporarily manifested competence", # omnicrumb
	"Implemented Pluey", # omnicrumb
	"Combined codebase into one file for organization", # omnicrumb
	"\n • \n • Where...\n • Where am I?\n • Hello...? Anyone...?\n • Is... is anybody out there...?\n • Someone!? Anyone!? Can anyone hear me!?\n • ...\n • It's dark.\n • It's so dark here.\n • Someone, anyone, if you can hear me...\n • Say something... please...",
]
var OPTIONS:Array[Callable] = [undergrounds, extraTime, extraSpace]

enum CONTEXT {EXPLAIN, OPTIONTEXT, APPLY, IMAGE}

@onready var menu:Menu = get_node("/root/menu")
@onready var game:Game = get_node("../..")

var options = [undergrounds, extraTime, extraSpace]

func loadNext() -> void:
	%version.text = "Build " + str(game.rounds+1)

	if game.rounds == 1: %body.text = " • There is now a timer. You must fulfill all requests of the next round within 60s"
	elif game.rounds > 1: %body.text = " • 45s has been added to the timer"

	%body.text += "\n • Added 4 extra chunks of map space\n"

	match game.itemTypesUnlocked[-1]:
		Items.TYPES.FRIDGE: %body.text += " • Fridge item has been implemented, but it is currently incompatible with underpaths"
		Items.TYPES.MAGNET: %body.text += " • Magnet item has been implemented, but it currently cannot be pathed orthoganally adjacent to metallic items"
	
	%body.text += "\n • "
	%body.text += FLAVOR_TEXT[randi_range(0, len(FLAVOR_TEXT)-1)]

	%body.text += "\n\nDue to these changes, there is a choice of versions for this build.\n"

	for option in 3:
		var optionNode:HBoxContainer = %options.get_child(option*2)
		optionNode.get_child(0).texture = options[option].call(CONTEXT.IMAGE)
		optionNode.get_child(1).text = "[url]" + options[option].call(CONTEXT.OPTIONTEXT) + "[/url]"
		%body.text += options[option].call(CONTEXT.EXPLAIN)

func _optionChosen(_meta, which:int) -> void: # i think theres a way to remove the first param bu	t i cant bother to figure it out
	options[which].call(CONTEXT.APPLY)
	menu.consolePrint("Option %s chosen, next round starting" % [which+1])
	game.nextRound()

func undergrounds(context:CONTEXT):
	match context:
		CONTEXT.OPTIONTEXT: return "[b]ThingDeliverer-underpaths.zip[/b]"
		CONTEXT.EXPLAIN: return "\nThe underpaths option includes five extra underpaths."
		CONTEXT.IMAGE: return preload("res://resources/ui/undergroundUnselected.png")
		CONTEXT.APPLY: game.undergroundsAvailable += 5
	
func extraTime(context:CONTEXT):
	match context:
		CONTEXT.OPTIONTEXT: return "[b]ThingDeliverer-extra_time.zip[/b]"
		CONTEXT.EXPLAIN: return "\nThe extra time option includes 30s of extra time."
		CONTEXT.IMAGE: return preload("res://resources/ui/hourglass.png")
		CONTEXT.APPLY: game.timeLeft += 30

func extraSpace(context:CONTEXT):
	match context:
		CONTEXT.OPTIONTEXT: return "[b]ThingDeliverer-ram_patch.zip[/b]"
		CONTEXT.EXPLAIN: return "\nThe ram patch option includes 6 extra chunks of map space."
		CONTEXT.IMAGE: return preload("res://resources/ui/cube.png")
		CONTEXT.APPLY: for _i in 6: game.randomNewSpace()
