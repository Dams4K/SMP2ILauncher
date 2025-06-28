extends Node

@onready var capes_release: LatestRelease = $CapesRelease
@onready var overrides_release: LatestRelease = $OverridesRelease

@onready var java: Java = $Java
@onready var forge: Forge = $Forge

@onready var assets: Assets = $Assets

func install():
	#capes_release.install()
	#overrides_release.install()
	#forge.install()
	assets.install()
