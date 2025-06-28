extends Node

@onready var java: Java = $Java
@onready var releases: Node = $Releases

@onready var forge: Forge = $Forge

@onready var assets: Assets = $Assets

func install():
	releases.install()
	#forge.install()
	
	#assets.install()

func run():
	var execute := JavaExecutor.new()
