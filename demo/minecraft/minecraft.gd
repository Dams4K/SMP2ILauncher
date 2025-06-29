extends Progressor

@onready var java: Java = $Java
@onready var releases: Node = $Releases

@onready var minecraft_installer: Progressor = $MinecraftInstaller

func install():
	releases.install()
	#forge.install()
	
	#assets.install()
	minecraft_installer.install()

func run(player_name: String):
	var executor := JavaExecutor.new()
	
	java.execute(executor)

func get_progress() -> int:
	return minecraft_installer.get_progress()
