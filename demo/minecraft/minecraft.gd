extends Progressor

@onready var java: Java = $Java
@onready var forge: Forge = $Forge
@onready var releases: Progressor = $Releases

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
	return minecraft_installer.get_progress() + java.get_progress() + releases.get_progress() + forge.get_progress()
