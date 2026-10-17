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
var pending_event: bool = false
var last_event_id: String = ""
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
	pending_event = false
	last_event_id = ""
	offers = []
	event_id = ""
	phase = "ready"
	remaining = 0
	shift_clicks = 0
	combo = 0
	since_tap = 99
	extension_used = 0
	save_clock = 0
	state = State.PLAYING
	persist()
	SceneManager.show_screen("game")

func has_save() -> bool:
	return SaveManager.progression.get("game_version") == 1 or SaveManager.progression.get("game_version") == 2

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

func fixed_extension() -> float:
	return minf(power("cafecito") + power("team"), balance.max_shift_extension)

func eligible_upgrade(item: FlightDefinition) -> bool:
	if item == null:
		return false
	if item.id == "cabrito":
		return burst_clicks < balance.burst_cap
	if count(item.id) >= item.max_level:
		return false
	if item.id in ["cafecito", "team"] and fixed_extension() >= balance.max_shift_extension:
		return false
	if item.id == "playlist" and fixed_extension() >= balance.max_shift_extension:
		return false
	return true

func upgrade_offers() -> Array:
	var fresh: Array = []
	var owned: Array = []
	for item: FlightDefinition in FlightCatalog.UPGRADES:
		if eligible_upgrade(item):
			if count(item.id) == 0:
				fresh.append(item.id)
			else:
				owned.append(item.id)
	var result: Array = []
	while result.size() < 3 and (not fresh.is_empty() or not owned.is_empty()):
		var use_new := owned.is_empty() or (not fresh.is_empty() and rng.randf() < balance.new_ability_weight)
		var pool: Array = fresh if use_new else owned
		result.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return result

func start_shift() -> void:
	if phase != "ready" or state != State.PLAYING:
		return
	remaining = balance.shift_seconds + fixed_extension()
	shift_clicks = 0
	combo = 0
	since_tap = 99
	extension_used = 0
	save_clock = 0
	set_phase("work")

func _process(delta: float) -> void:
	advance_time(delta)

func advance_time(delta: float) -> void:
	if state != State.PLAYING or phase != "work":
		return
	var elapsed := minf(maxf(delta, 0), remaining)
	since_tap = minf(100, since_tap + elapsed)
	remaining = maxf(0, remaining - elapsed)
	var passive := (power("empire") + relic_power("postcard"))
	money += elapsed * passive * base_income() * global_multiplier()
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
		multiplier *= 1.0 + minf(combo * power("love"), 0.9)
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
		var budget := minf(balance.playlist_extension_cap, balance.max_shift_extension - fixed_extension())
		var extra := maxf(0, minf(power("playlist"), budget - extension_used))
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
	money *= 1.0 + minf(power("jar"), 0.06)
	offers = upgrade_offers()
	pending_event = days % maxi(1, balance.event_interval) == 0
	event_id = ""
	if pending_event:
		var events := random_ids(FlightCatalog.EVENTS, 1, [last_event_id])
		if events.is_empty():
			events = random_ids(FlightCatalog.EVENTS, 1)
		event_id = events[0]
	if offers.is_empty():
		complete_reward()
	else:
		set_phase("upgrades")

func complete_reward() -> void:
	offers = []
	set_phase("event" if pending_event else "ready")

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
	# Retain the public action name for existing scene callers; rewards are free.
	if phase != "upgrades" or id not in offers:
		return false
	var item := FlightCatalog.find_item(FlightCatalog.UPGRADES, id)
	if item == null or not eligible_upgrade(item):
		return false
	apply_upgrade(item)
	complete_reward()
	return true

func add_burst(amount: int) -> void:
	burst_clicks = mini(balance.burst_cap, burst_clicks + amount)

func apply_upgrade(item: FlightDefinition) -> void:
	if item == null or not eligible_upgrade(item):
		return
	upgrades[item.id] = count(item.id) + 1
	match item.effect:
		"burst": add_burst(int(item.amount))
		"discount": goal_multiplier = maxf(0.5, goal_multiplier * (1.0 - item.amount))

func next_day() -> void:
	# Required rewards cannot be skipped by stale UI callbacks.
	if phase == "upgrades" and offers.is_empty():
		complete_reward()

func resolve_event(alternative: bool = false) -> void:
	if phase != "event":
		return
	var item := FlightCatalog.find_item(FlightCatalog.EVENTS, event_id)
	if item == null:
		return
	var effect := item.alternative_effect if alternative else item.effect
	var amount := item.alternative_amount if alternative else item.amount
	amount *= 1.0 + power("blessing")
	match effect:
		"gift": money += amount * base_income() * global_multiplier()
		"burst": add_burst(int(ceilf(amount)))
	last_event_id = event_id
	event_id = ""
	pending_event = false
	set_phase("ready")

func buy_trip() -> bool:
	if phase != "ready" or money < goal():
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
	pending_event = false
	last_event_id = ""
	remaining = 0
	offers = []
	if has_relic("kiss"):
		apply_upgrade(FlightCatalog.find_item(FlightCatalog.UPGRADES, "appointment"))
	set_phase("ready")

func snapshot() -> Dictionary:
	return {"game_version": 2, "chapter": chapter, "money": money, "days": days, "total_days": total_days,
		"completed_chapters": completed_chapters.duplicate(), "complete": complete, "upgrades": upgrades.duplicate(),
		"relics": relics.duplicate(), "phase": phase, "offers": offers.duplicate(), "event_id": event_id,
		"goal_multiplier": goal_multiplier, "remaining": remaining, "shift_clicks": shift_clicks,
		"burst_clicks": burst_clicks, "pending_event": pending_event, "last_event_id": last_event_id, "combo": combo, "since_tap": since_tap, "extension_used": extension_used}

func persist() -> void:
	SaveManager.progression = snapshot()
	save_error = SaveManager.save_data() != OK

func restore(data: Dictionary) -> bool:
	if data.get("game_version") != 1 and data.get("game_version") != 2:
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
		var level := int(safe_number(saved_upgrades.get(item.id), 0, item.max_level if item.max_level > 0 else 100000))
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
	remaining = safe_number(data.get("remaining"), 0, balance.shift_seconds + balance.max_shift_extension)
	shift_clicks = int(safe_number(data.get("shift_clicks"), 0, 100000))
	burst_clicks = int(safe_number(data.get("burst_clicks"), 0, balance.burst_cap))
	pending_event = data.get("pending_event", false) == true
	last_event_id = str(data.get("last_event_id", ""))
	combo = int(safe_number(data.get("combo"), 0, 6))
	since_tap = safe_number(data.get("since_tap"), 99, 100)
	extension_used = safe_number(data.get("extension_used"), 0, balance.playlist_extension_cap)
	# v0.1 decisions are retained, but old shops become one mandatory free reward.
	# Move legacy events behind their unclaimed free reward, retaining the event ID.
	if data.get("game_version") == 1:
		pending_event = phase == "event"
		if pending_event:
			phase = "upgrades"
	if pending_event and FlightCatalog.find_item(FlightCatalog.EVENTS, event_id) == null:
		event_id = random_ids(FlightCatalog.EVENTS, 1, [last_event_id])[0]
	if phase == "upgrades":
		offers = offers.filter(func(id: String) -> bool:
			return eligible_upgrade(FlightCatalog.find_item(FlightCatalog.UPGRADES, id)))
		if offers.is_empty():
			offers = upgrade_offers()
		if offers.is_empty():
			phase = "event" if pending_event else "ready"
	remaining = minf(remaining, balance.shift_seconds + fixed_extension() + minf(balance.playlist_extension_cap, balance.max_shift_extension - fixed_extension()))
	save_clock = 0
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
