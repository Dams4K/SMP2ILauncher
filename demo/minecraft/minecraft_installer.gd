extends Progressor

@onready var minecraft_tweaker: MinecraftTweaker = $MinecraftTweaker

var progress: int = 0

func install() -> void:
	minecraft_tweaker.install()

func get_progress():
	return minecraft_tweaker.get_progress()
