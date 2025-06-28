extends Node

@onready var capes_release: LatestRelease = $CapesRelease
@onready var overrides_release: LatestRelease = $OverridesRelease

func install():
	capes_release.install()
	overrides_release.install()
