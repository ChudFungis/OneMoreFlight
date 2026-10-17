class_name FlightResults
extends RefCounted
## Local completed-run ledger, owned by SaveManager; never part of active progression.
const HISTORY_LIMIT := 5
var save_path: String = "user://results.json"
var next_attempt: int = 1
var last_recorded_attempt: int = 0
var recent: Array = []
var best: Dictionary = {}
var last_error: Error = OK

func positive_int(value: Variant, maximum: int = 2000000000) -> int:
	if (value is int or value is float) and is_finite(float(value)):
		if float(value) == floorf(float(value)) and float(value) > 0 and float(value) <= maximum:
			return int(value)
	return 0

func valid_record(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return {}
	var attempt := positive_int(value.get("attempt"))
	var total := positive_int(value.get("total_days"), 300000)
	if attempt == 0 or total == 0:
		return {}
	var chapters: Array = []
	var source: Variant = value.get("chapter_days", [])
	if source is Array and source.size() == 3:
		var sum_days := 0
		for entry: Variant in source:
			var count_days := positive_int(entry, 100000)
			if count_days == 0:
				return {}
			chapters.append(count_days)
			sum_days += count_days
		if sum_days != total:
			return {}
	var date: String = value.get("completed_at", "") if value.get("completed_at", "") is String else ""
	# Only display ISO-like timestamps; an unavailable date is harmless.
	if date.length() > 32 or (not date.is_empty() and date.substr(4, 1) != "-"):
		date = ""
	return {"attempt": attempt, "total_days": total, "chapter_days": chapters, "completed_at": date}

func load_data() -> void:
	next_attempt = 1
	last_recorded_attempt = 0
	recent = []
	best = {}
	last_error = OK
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		last_error = FileAccess.get_open_error()
		return
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not parser.data is Dictionary:
		push_warning("Invalid results file; using an empty local history.")
		return
	var data: Dictionary = parser.data
	if data.get("version") != 1:
		return
	last_recorded_attempt = positive_int(data.get("last_recorded_attempt"))
	next_attempt = maxi(1, positive_int(data.get("next_attempt")))
	best = valid_record(data.get("best"))
	var entries: Variant = data.get("recent", [])
	var ids: Array = []
	if entries is Array:
		for value: Variant in entries:
			var entry := valid_record(value)
			if not entry.is_empty() and entry.attempt not in ids:
				recent.append(entry)
				ids.append(entry.attempt)
	recent.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.attempt > b.attempt)
	for entry: Dictionary in recent:
		if best.is_empty() or entry.total_days < best.total_days:
			best = entry.duplicate(true)
		last_recorded_attempt = maxi(last_recorded_attempt, entry.attempt)
	if not best.is_empty():
		last_recorded_attempt = maxi(last_recorded_attempt, best.attempt)
	next_attempt = maxi(next_attempt, last_recorded_attempt + 1)
	recent = recent.slice(0, HISTORY_LIMIT)

func save_data() -> Error:
	var file := FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		last_error = FileAccess.get_open_error()
		return last_error
	file.store_string(JSON.stringify({"version": 1, "next_attempt": next_attempt,
		"last_recorded_attempt": last_recorded_attempt, "recent": recent, "best": best}, "\t"))
	file.flush()
	last_error = file.get_error()
	file.close()
	if last_error == OK:
		last_error = DirAccess.rename_absolute(save_path + ".tmp", save_path)
	return last_error

func begin_attempt() -> int:
	var attempt := next_attempt
	next_attempt += 1
	save_data()
	return attempt

func has_recorded(attempt: int) -> bool:
	# A watermark prevents old snapshots duplicating runs after their history expires.
	return attempt > 0 and attempt <= last_recorded_attempt

func record_run(attempt: int, total: int, chapters: Array, date: String) -> bool:
	if has_recorded(attempt):
		return false
	var entry := valid_record({"attempt": attempt, "total_days": total, "chapter_days": chapters, "completed_at": date})
	if entry.is_empty():
		return false
	var new_best := best.is_empty() or total < int(best.total_days)
	if new_best:
		best = entry.duplicate(true)
	recent.push_front(entry)
	recent = recent.slice(0, HISTORY_LIMIT)
	last_recorded_attempt = attempt
	next_attempt = maxi(next_attempt, attempt + 1)
	save_data()
	return new_best
