extends Node
## Local settings and versioned campaign snapshot; user:// maps to browser storage on Web.
const SAVE_PATH := "user://save_data.json"
var settings: Dictionary = {"music_volume": 0.8, "sfx_volume": 0.8, "fullscreen": false}
var progression: Dictionary = {}
var save_path: String = SAVE_PATH

func _ready() -> void:
	load_data()

func load_data() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_warning("Could not read save file.")
		return
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	var data: Variant = parser.data
	if parse_error != OK or not data is Dictionary:
		push_warning("Invalid save file; using current defaults.")
		return
	var saved: Variant = data.get("settings", {})
	if saved is Dictionary:
		for key: String in ["music_volume", "sfx_volume"]:
			var value: Variant = saved.get(key)
			if (value is float or value is int) and is_finite(float(value)):
				settings[key] = clampf(float(value), 0.0, 1.0)
		if saved.get("fullscreen") is bool:
			settings["fullscreen"] = saved["fullscreen"]
	if data.get("progression") is Dictionary:
		progression = data["progression"]

func save_data() -> Error:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_warning("Could not save settings: %s" % error_string(FileAccess.get_open_error()))
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify({"version": 1, "settings": settings, "progression": progression}, "\t"))
	file.flush()
	var result := file.get_error()
	file.close()
	return result
