extends Progressor
class_name Forge

const INSTALLED_PROGRESS_VALUE := 100

@export var java: Java
@export_file var installer: String

@export var installation_folder := "user://"

func install():
	_create_profile()
	_copy_installer()
	_execute_installer()

func _create_profile():
	var profile = FileAccess.open(installation_folder.path_join("launcher_profiles.json"), FileAccess.WRITE)
	profile.store_string(JSON.stringify({}))

func _get_installer_path():
	return installation_folder.path_join(installer.get_file())

func _copy_installer():
	DirAccess.make_dir_recursive_absolute(installation_folder)
	var err = DirAccess.copy_absolute(installer, _get_installer_path())
	assert(err == OK, "Error while copying installer: %s" % err)

func _execute_installer():
	var executor := JavaExecutor.new(["-jar", global(_get_installer_path()), "--installClient", global(installation_folder)])
	java.execute(executor, _on_executed)

func _on_executed(exit_code: int, output: Array):
	assert(exit_code == 0, "Failed to install forge (exit code: %s)" % exit_code)
	print_debug("Forge installed at %s" % global(installation_folder))
	_progress = INSTALLED_PROGRESS_VALUE

func global(path: String):
	return ProjectSettings.globalize_path(path)
