extends Node
class_name Assets

const RESOURCES_URL = "https://resources.download.minecraft.net/"

@export var assets_folder := "user://assets"

var requester: Requests

func _ready() -> void:
	_init_requester()

func _init_requester():
	requester = Requests.new()
	add_child(requester)

func install(assets_index: AssetsIndex):
	pass

func get_assets_list(assets_index: AssetsIndex) -> Dictionary:
	var assets_index_path = assets_folder.path_join("indexes/%s.json" % assets_index.get_id())
	await requester.do_file(assets_index.get_url(), assets_index_path, assets_index.get_sha1())
	
	var assets_index_file = FileAccess.open(assets_index_path, FileAccess.READ)
	if assets_index_file == null or assets_index_file.get_error() != OK:
		push_error("Error opening file %s" % assets_index_file)
		return {}
	
	var content: Dictionary = JSON.parse_string(assets_index_file.get_as_text())
	var objects: Dictionary = content.get("objects", {})
	
	return objects
