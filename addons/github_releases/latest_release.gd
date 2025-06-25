extends Node
class_name LatestRelease

@export var owner_name: String
@export var repository: String

var requests: Requests
var http_request: HTTPRequest
var extractor: Extractor

var zip_file := ""
var to_folder := ""
var delete_archive := true
var tag_name := ""

func _ready() -> void:
	_init_requests()
	_init_http_request()
	_init_extractor()

func _init_requests():
	requests = Requests.new()
	add_child(requests)

func _init_http_request():
	http_request = HTTPRequest.new()
	http_request.request_completed.connect(_on_downloaded)
	http_request.accept_gzip = true
	http_request.use_threads = true
	add_child(http_request)

func _init_extractor():
	extractor = Extractor.new()
	extractor.extracted.connect(_on_extracted)

func get_url() -> StringName:
	return "https://api.github.com/repos/%s/%s/releases/latest" % [owner_name, repository]

func download_zipball(to: String, force_update := false, delete_archive := true):
	self.to_folder = to
	self.zip_file = "%s.zip" % to_folder
	self.delete_archive = delete_archive
	
	DirAccess.make_dir_recursive_absolute(to_folder)
	
	var response: Dictionary = (await requests.do_get(get_url())).json()
	
	tag_name = response.get("tag_name", "")
	if not force_update:
		var tag_file = get_tag_file(to_folder, FileAccess.READ)
		if tag_file != null and tag_name == tag_file.get_line():
			print_debug("Skipping. %s already installed" % repository)
			return
	
	var zipball_url: String = response.get("zipball_url", "")
	assert(not zipball_url.is_empty(), "zipball url is empty")
	
	http_request.download_file = zip_file
	http_request.request(zipball_url)

func get_tag_path(dir: String) -> String:
	return dir.path_join(".repo_tag_name")

func get_tag_file(dir: String, flag: FileAccess.ModeFlags) -> FileAccess:
	return FileAccess.open(get_tag_path(dir), flag)

func _on_downloaded(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	assert(result == HTTPRequest.RESULT_SUCCESS, "Request failed: %s" % result)
	
	extractor.extract(zip_file)

func _on_extracted():
	var tag_file := get_tag_file(to_folder, FileAccess.WRITE)
	tag_file.store_line(tag_name)
	
	print("Latest release of %s is now installed at %s" % [repository, to_folder])
	if delete_archive:
		DirAccess.remove_absolute(zip_file)
