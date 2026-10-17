extends Node
## All economy rules live here; presentation only calls actions and listens to signals.
signal changed
signal phase_changed
signal earned(amount: float)
signal notice(message: String)
enum State { MENU, PLAYING, PAUSED, GAME_OVER }
var balance: FlightBalance = preload("res://resources/balance.tres")
const CHAPTERS := ["Denver: The First Flight", "Italy: La Dolce Vita", "Our Future: One-Way Ticket"]
const DESTINATIONS := ["Monterrey → Denver", "Monterrey → Italy", "Monterrey → Our Future"]
var state: State = State.MENU
var chapter: int = 0
var money: float = 0.0
var days: int = 0
var total_days: int = 0
var completed_chapters: Array = []
var complete: bool = false
var upgrades: Dictionary = {}
var relics: Array = []
var phase: String = "ready"
var offers: Array = []
var event_id: String = ""
var goal_multiplier: float = 1.0
var remaining: float = 0.0
var shift_clicks: int = 0
var burst_clicks: int = 0
var shields: int = 0
var combo: int = 0
var since_tap: float = 99.0
var extension_used: float = 0.0
var save_clock: float = 0.0
var save_error: bool = false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	process_mode = Node.PROCESS_MODE_PAUSABLE

func count(id: String) -> int:
	return int(upgrades.get(id, 0))

func power(id: String) -> float:
	var item := FlightCatalog.find_item(FlightCatalog.UPGRADES, id)
	return count(id) * item.amount if item != null else 0.0

func relic_power(id: String) -> float:
	var item := FlightCatalog.find_item(FlightCatalog.RELICS, id)
	return item.amount if has_relic(id) and item != null else 0.0

func has_relic(id: String) -> bool:
	return id in relics

func base_income() -> float:
	return balance.click_income * balance.chapter_income[chapter]

func goal() -> float:
	return balance.goals[chapter] * goal_multiplier * (1.0 - relic_power("passport"))

func price(item: FlightDefinition) -> float:
	return roundf(item.price * balance.price_scale[chapter] * (1.0 + count(item.id) * 0.35))

func global_multiplier() -> float:
	return 1.0 + relic_power("bracelet")

func new_game() -> void:
	chapter = 0
	money = 0
	days = 0
	total_days = 0
	completed_chapters = []
	complete = false
	upgrades = {}
	relics = []
	goal_multiplier = 1.0
	burst_clicks = 0
	shields = 0
	offers = []
	event_id = ""
	phase = "ready"
	remaining = 0
	state = State.PLAYING
	persist()
	SceneManager.show_screen("game")

func has_save() -> bool:
	return SaveManager.progression.get("game_version") == 1

func continue_game() -> void:
	if not restore(SaveManager.progression):
		return
	state = State.PLAYING
	SceneManager.show_screen("game")

func set_phase(value: String) -> void:
	phase = value
	persist()
	phase_changed.emit()
	changed.emit()

func start_shift() -> void:
	if phase != "ready" or state != State.PLAYING:
		return
	remaining = balance.shift_seconds + minf(power("cafecito"), balance.max_shift_extension)
	shift_clicks = 0
	combo = 0
	since_tap = 99
	extension_used = 0
	set_phase("work")

func _process(delta: float) -> void:
	advance_time(delta)

func advance_time(delta: float) -> void:
	if state != State.PLAYING or phase != "work":
		return
	var elapsed := minf(maxf(delta, 0), remaining)
	since_tap += elapsed
	remaining = maxf(0, remaining - elapsed)
	var passive := (power("empire") + relic_power("postcard"))
	money += elapsed * passive * base_income() * (1.0 + power("team")) * global_multiplier()
	save_clock += elapsed
	changed.emit()
	if remaining <= 0:
		finish_shift()
	elif save_clock >= 2.0:
		save_clock = 0
		persist()

func tap() -> float:
	if phase != "work" or state != State.PLAYING or remaining <= 0:
		return 0
	combo = mini(combo + 1, 6) if since_tap <= balance.combo_window else 1
	since_tap = 0
	shift_clicks += 1
	var multiplier := 1.0 + power("appointment")
	if count("love") > 0:
		multiplier *= 1.0 + minf(combo * power("love"), 1.2)
	if burst_clicks > 0:
		multiplier *= 2
		burst_clicks -= 1
	if has_relic("hoodie") and shift_clicks <= 10:
		multiplier *= 1.0 + relic_power("hoodie")
	var reward := base_income() * multiplier
	if shift_clicks % 10 == 0:
		reward += base_income() * (power("facetime") + relic_power("unlimited"))
	if shift_clicks % 7 == 0:
		reward += base_income() * power("tips")
	if shift_clicks % 5 == 0 and count("playlist") > 0:
		var extra := minf(power("playlist"), 3.0 - extension_used)
		remaining += extra
		extension_used += extra
	reward *= global_multiplier()
	money += reward
	earned.emit(reward)
	changed.emit()
	return reward

func finish_shift() -> void:
	if phase != "work":
		return
	days += 1
	total_days += 1
	money *= 1.0 + minf(power("jar"), 0.4)
	offers = random_ids(FlightCatalog.UPGRADES, 3)
	if days % maxi(1, balance.event_interval) == 0 and rng.randf() < balance.event_probability:
		event_id = FlightCatalog.EVENTS[rng.randi_range(0, FlightCatalog.EVENTS.size() - 1)].id
		set_phase("event")
	else:
		set_phase("upgrades")

func random_ids(items: Array, size_wanted: int, excluded: Array = []) -> Array:
	var pool: Array = []
	for item: FlightDefinition in items:
		if item.id not in excluded:
			pool.append(item.id)
	var result: Array = []
	while result.size() < size_wanted and not pool.is_empty():
		var index := rng.randi_range(0, pool.size() - 1)
		result.append(pool.pop_at(index))
	return result

func buy_upgrade(id: String) -> bool:
	if phase != "upgrades" or id not in offers:
		return false
	var item := FlightCatalog.find_item(FlightCatalog.UPGRADES, id)
	if item == null or money < price(item):
		return false
	money -= price(item)
	apply_upgrade(item)
	offers.erase(id)
	persist()
	phase_changed.emit()
	changed.emit()
	return true

func apply_upgrade(item: FlightDefinition) -> void:
	upgrades[item.id] = count(item.id) + 1
	match item.effect:
		"burst": burst_clicks += int(item.amount)
		"shield": shields += int(item.amount)
		"discount": goal_multiplier = maxf(0.5, goal_multiplier * (1.0 - item.amount))
		"team": money += base_income() * 12

func next_day() -> void:
	if phase == "upgrades":
		offers = []
		set_phase("ready")

func resolve_event(alternative: bool = false) -> void:
	if phase != "event":
		return
	var item := FlightCatalog.find_item(FlightCatalog.EVENTS, event_id)
	if item == null:
		set_phase("upgrades")
		return
	var effect := item.alternative_effect if alternative and not item.alternative.is_empty() else item.effect
	var amount := item.alternative_amount if alternative and not item.alternative.is_empty() else item.amount
	if effect == "loss" and shields > 0:
		shields -= 1
		notice.emit.call_deferred("Abuela’s Blessing protected your savings!")
	else:
		match effect:
			"loss": money *= 1.0 - amount
			"gift": money += amount * base_income() * global_multiplier()
			"burst": burst_clicks += int(amount)
			"discount": goal_multiplier = maxf(0.5, goal_multiplier * (1.0 - amount))
			"invest":
				money *= 1.0 - amount
				apply_upgrade(FlightCatalog.find_item(FlightCatalog.UPGRADES, "appointment"))
	event_id = ""
	set_phase("upgrades")

func buy_trip() -> bool:
	if phase not in ["ready", "upgrades"] or money < goal():
		return false
	money -= goal()
	if chapter not in completed_chapters:
		completed_chapters.append(chapter)
	if chapter == 2:
		complete = true
	set_phase("story")
	return true

func finish_story() -> void:
	if phase != "story":
		return
	if chapter == 2:
		set_phase("ending")
	else:
		offers = random_ids(FlightCatalog.RELICS, 3, relics)
		set_phase("relic")

func choose_relic(id: String) -> void:
	if phase != "relic" or id not in offers or id in relics:
		return
	relics.append(id)
	chapter += 1
	money = 0
	days = 0
	upgrades = {}
	goal_multiplier = 1
	burst_clicks = 0
	shields = 0
	remaining = 0
	offers = []
	if has_relic("kiss"):
		apply_upgrade(FlightCatalog.find_item(FlightCatalog.UPGRADES, "appointment"))
	set_phase("ready")

func snapshot() -> Dictionary:
	return {"game_version": 1, "chapter": chapter, "money": money, "days": days, "total_days": total_days,
		"completed_chapters": completed_chapters.duplicate(), "complete": complete, "upgrades": upgrades.duplicate(),
		"relics": relics.duplicate(), "phase": phase, "offers": offers.duplicate(), "event_id": event_id,
		"goal_multiplier": goal_multiplier, "remaining": remaining, "shift_clicks": shift_clicks,
		"burst_clicks": burst_clicks, "shields": shields, "combo": combo, "since_tap": since_tap, "extension_used": extension_used}

func persist() -> void:
	SaveManager.progression = snapshot()
	save_error = SaveManager.save_data() != OK

func restore(data: Dictionary) -> bool:
	if data.get("game_version") != 1:
		return false
	chapter = clampi(int(data.get("chapter", 0)), 0, 2)
	money = safe_number(data.get("money"), 0, 1e12)
	days = int(safe_number(data.get("days"), 0, 100000))
	total_days = int(safe_number(data.get("total_days"), days, 300000))
	completed_chapters = []
	for value: Variant in data.get("completed_chapters", []) if data.get("completed_chapters") is Array else []:
		if value in [0, 1, 2] and value not in completed_chapters:
			completed_chapters.append(int(value))
	complete = data.get("complete", false) == true
	upgrades = {}
	var saved_upgrades: Dictionary = data.get("upgrades", {}) if data.get("upgrades") is Dictionary else {}
	for item: FlightDefinition in FlightCatalog.UPGRADES:
		var level := int(safe_number(saved_upgrades.get(item.id), 0, 100))
		if level > 0:
			upgrades[item.id] = level
	relics = []
	for id: Variant in data.get("relics", []) if data.get("relics") is Array else []:
		if id is String and FlightCatalog.find_item(FlightCatalog.RELICS, id) != null and id not in relics:
			relics.append(id)
	phase = str(data.get("phase", "ready"))
	if phase not in ["ready", "work", "upgrades", "event", "story", "relic", "ending"]:
		phase = "ready"
	offers = []
	var catalog: Array = FlightCatalog.RELICS if phase == "relic" else FlightCatalog.UPGRADES
	for id: Variant in data.get("offers", []) if data.get("offers") is Array else []:
		if id is String and FlightCatalog.find_item(catalog, id) != null and id not in offers:
			offers.append(id)
	event_id = str(data.get("event_id", ""))
	if phase == "event" and FlightCatalog.find_item(FlightCatalog.EVENTS, event_id) == null:
		phase = "upgrades"
	goal_multiplier = clampf(safe_number(data.get("goal_multiplier"), 1, 1), 0.5, 1)
	remaining = safe_number(data.get("remaining"), 0, balance.shift_seconds + balance.max_shift_extension + 3)
	shift_clicks = int(safe_number(data.get("shift_clicks"), 0, 100000))
	burst_clicks = int(safe_number(data.get("burst_clicks"), 0, 100000))
	shields = int(safe_number(data.get("shields"), 0, 100))
	combo = int(safe_number(data.get("combo"), 0, 6))
	since_tap = safe_number(data.get("since_tap"), 99, 100)
	extension_used = safe_number(data.get("extension_used"), 0, 3)
	return true

func safe_number(value: Variant, fallback: float, maximum: float) -> float:
	if (value is float or value is int) and is_finite(float(value)):
		return clampf(float(value), 0, maximum)
	return fallback

func main_menu() -> void:
	if state != State.MENU:
		persist()
	state = State.MENU
	SceneManager.show_screen("main_menu")

func set_state(value: State) -> void:
	state = value
	changed.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and state == State.PLAYING:
		persist()
		if is_instance_valid(SceneManager.screen_host):
			SceneManager.pause_run()
