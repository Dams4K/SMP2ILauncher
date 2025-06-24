extends Node
class_name Java

#@export var options: Dictionary[String, String] = {}

signal finished(output: Array)

#region Download Section

@export var installation_folder: String
@export var executable_path := "bin/java"

@export_group("Download URLs")
@export var linux_download_url: String
@export var windows_download_url: String
@export var macos_download_url: String

var http_request: HTTPRequest
var extractor: Extractor

var is_installing := false
# Variable used when we try to execute and java isn't installed
var must_execute: JavaExecutor

func _ready() -> void:
	_init_http_request()
	_init_extractor()

func _init_http_request():
	http_request = HTTPRequest.new()
	http_request.request_completed.connect(_on_downloaded)
	http_request.accept_gzip = true
	http_request.use_threads = true
	add_child(http_request)

func _init_extractor():
	extractor = Extractor.new()
	extractor.extracted.connect(_on_extracted)

func is_installed() -> bool:
	if not FileAccess.file_exists(get_executable()):
		return false
	
	var test_executor := JavaExecutor.new()
	return _jprocess(test_executor) != -1

func install():
	if is_installing:
		return # No need to download again
	
	is_installing = true
	
	if download(get_download_url()) != OK:
		push_error("An error occurred in the download request")
		is_installing = false

func get_download_url() -> String:
	var url: String = ""
	
	match OS.get_name():
		"Windows":
			url = windows_download_url
		"macOS":
			url = macos_download_url
		"Linux":
			url = linux_download_url
	
	return url

func get_download_file() -> String:
	var url := get_download_url()
	return installation_folder.path_join(url.get_file())

func download(url: String) -> int:
	assert(not url.is_empty(), "Download url is empty")
	
	var download_file = get_download_file()
	DirAccess.make_dir_recursive_absolute(download_file.get_base_dir())
	
	http_request.download_file = download_file
	return http_request.request(url, PackedStringArray(), HTTPClient.METHOD_GET, "")

func _on_downloaded(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	assert(result == HTTPRequest.RESULT_SUCCESS, "Request failed: %s" % result)
	
	extractor.extract(get_download_file())

func _on_extracted():
	is_installing = false
	
	if must_execute != null:
		# We don't want to enter a loop where is_installed return false and java is downloaded again
		_jprocess(must_execute)
#endregion

func get_executable() -> String:
	var url := get_download_url()
	var path := installation_folder.path_join(url.get_file().get_basename()).path_join(executable_path)
	return ProjectSettings.globalize_path(path)

#func execute(executor: JavaExecutor):
	#if not is_installed():
		#must_execute = executor
		#install()
	#else:
		#_execute(executor)
#
#func _execute(executor: JavaExecutor) -> int:
	#var executable: String = get_executable()
	#var output = []
	#var result = OS.execute(executable, executor.as_arguments(), output, true, executor.open_console)
	#finished.emit(output)
	#return result

func jprocess(executor: JavaExecutor):
	if not is_installed():
		must_execute = executor
		install()
	else:
		_jprocess(executor)

func _jprocess(executor: JavaExecutor) -> int:
	var executable: String = get_executable()
	return OS.create_process(executable, executor.as_arguments(), executor.open_console)
