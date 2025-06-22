extends Node
class_name MassDownloads

@export var nb_of_requesters := 4

var requesters: Array[HTTPRequest] = []

var _queue: Array[DownloadElement] = []
var _retry_queue: Array[DownloadElement] = []

func _ready() -> void:
	for i in range(nb_of_requesters):
		var hr := HTTPRequest.new()
		hr.use_threads = true
		hr.accept_gzip = true
		
		add_child(hr)
		requesters.append(hr)


func add_to_queue(url: String, path: String, sha1: String = ""):
	_queue.append(DownloadElement.new(url, path, sha1))
	ask_requesters()

func ask_requesters():
	for hr: HTTPRequest in requesters:
		if hr.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
			start_download_by(hr)
			break

func start_download_by(hr: HTTPRequest):
	if hr.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	
	var de: DownloadElement = _queue.pop_front()
	var from_retry := false
	if de == null:
		from_retry = true
		de = _retry_queue.pop_front()
	
	if de == null:
		return
	
	DirAccess.make_dir_recursive_absolute(de.path.get_base_dir())
	if FileAccess.file_exists(de.path):
		if de.sha1 == "":
			return
		elif Utils.check_sha1(de.path, de.sha1):
			return
	
	hr.request_completed.connect(_on_request_completed.bind(hr, de, from_retry))
	hr.download_file = de.path
	var err := hr.request(de.url, PackedStringArray(), HTTPClient.METHOD_GET, "")
	printt("Try donwload", de.url, de.path)
	if err != OK:
		print("Err: %s", err)

class DownloadElement extends RefCounted:
	var url: String
	var path: String
	var sha1: String
	
	func _init(url: String, path: String, sha1: String = "") -> void:
		self.url = url
		self.path = path
		self.sha1 = sha1

func _on_request_completed(
	result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray,
	http_request: HTTPRequest, de: DownloadElement, from_retry: bool
) -> void:
	http_request.request_completed.disconnect(_on_request_completed)
	if result != HTTPRequest.RESULT_SUCCESS:
		if from_retry:
			push_error("Error while downlaoding assets! %s" % result)
		else:
			_retry_queue.append(de)
	
	start_download_by(http_request)
