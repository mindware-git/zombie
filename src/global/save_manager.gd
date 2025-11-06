extends Node

const RELEASE_SAVE_FILE_PATH = "user://gamedata.tres"
const DEBUG_SAVE_FILE_PATH = "user://debug_gamedata.tres"

var save_path: String
var game_data = GameData.new()

func _ready() -> void:
	# Release 모드일 때만 format check 실행
	if OS.is_debug_build():
		save_path = DEBUG_SAVE_FILE_PATH
	else:
		save_path = RELEASE_SAVE_FILE_PATH

func format_check() -> void:
	if FileAccess.file_exists(save_path):
		game_data = ResourceLoader.load(save_path)
	else:
		ResourceSaver.save(game_data, save_path)

func save_game() -> void:
	ResourceSaver.save(game_data, save_path)

func remove_save_file() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
