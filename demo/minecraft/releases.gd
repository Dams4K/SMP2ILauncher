extends Progressor

@onready var capes_release: LatestRelease = $CapesRelease
@onready var overrides_release: LatestRelease = $OverridesRelease

func install():
	capes_release.install()
	overrides_release.install()

func get_progress():
	return capes_release.get_progress() + overrides_release.get_progress()
