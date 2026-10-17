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
var nicky_growth: float = 0.0
var save_clock: float = 0.0
var save_error: bool = false
var rng := RandomNumberGenerator.new()
var run_attempt: int = 0
var chapter_days: Array = []
var run_new_best: bool = false

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
	run_attempt = SaveManager.results.begin_attempt()
	chapter_days = []
	run_new_best = false
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
	phase = "transition"
	remaining = 0
	shift_clicks = 0
	nicky_growth = 0.0
	save_clock = 0
	state = State.PLAYING
	persist()
	SceneManager.show_screen("game")

func has_save() -> bool:
	var version: Variant = SaveManager.progression.get("game_version")
	return version == 1 or version == 2 or version == 3 or version == 4

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
	return power("team")

func eligible_upgrade(item: FlightDefinition) -> bool:
	if item == null or FlightCatalog.find_item(FlightCatalog.UPGRADES, item.id) == null:
		return false
	return item.max_level == 0 or count(item.id) < item.max_level

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
	if phase not in ["ready", "transition"] or state != State.PLAYING:
		return
	remaining = balance.shift_seconds + fixed_extension()
	shift_clicks = 0
	save_clock = 0
	set_phase("work")

func _process(delta: float) -> void:
	advance_time(delta)

func advance_time(delta: float) -> void:
	if state != State.PLAYING or phase != "work":
		return
	var elapsed := minf(maxf(delta, 0), remaining)
	var passive := relic_power("postcard")
	var passive_rate := passive * base_income() * global_multiplier()
	if passive_rate > 0:
		elapsed = minf(elapsed, maxf(0, (goal() - money) / passive_rate))
	remaining = maxf(0, remaining - elapsed)
	money += elapsed * passive_rate
	save_clock += elapsed
	changed.emit()
	if remaining <= 0 or money >= goal():
		finish_shift()
	elif save_clock >= 2.0:
		save_clock = 0
		persist()

func tap() -> float:
	if phase != "work" or state != State.PLAYING or remaining <= 0:
		return 0
	shift_clicks += 1
	# Nicky adds base-value growth; it does not retroactively multiply old taps.
	var multiplier := 1.0 + power("appointment") + nicky_growth
	if count("cabrito") > 0 and rng.randf() < critical_chance(count("cabrito")):
		multiplier *= 2
	# Existing event boosts remain separate from the permanent Cabrito ability.
	if burst_clicks > 0:
		multiplier *= 2
		burst_clicks -= 1
	if has_relic("hoodie") and shift_clicks <= 10:
		multiplier *= 1.0 + relic_power("hoodie")
	var reward := base_income() * multiplier
	if shift_clicks % balance.facetime_tap_interval == 0:
		reward += base_income() * (power("facetime") + relic_power("unlimited"))
	if shift_clicks % balance.music_tap_interval == 0:
		remaining += power("playlist")
	nicky_growth += power("love")
	reward *= global_multiplier()
	money += reward
	earned.emit(reward)
	changed.emit()
	if money >= goal():
		finish_shift()
	return reward

func critical_chance(level: int) -> float:
	var item := FlightCatalog.find_item(FlightCatalog.UPGRADES, "cabrito")
	return 1.0 - pow(1.0 - item.amount, level)

func interest_rate(level: int) -> float:
	if level <= 0:
		return 0.0
	var item := FlightCatalog.find_item(FlightCatalog.UPGRADES, "jar")
	return item.amount + (level - 1) * balance.interest_level_step

func ability_effect(id: String, level: int) -> String:
	var item := FlightCatalog.find_item(FlightCatalog.UPGRADES, id)
	if item == null or level <= 0:
		return "Not owned"
	match id:
		"appointment": return "+%d%% regular taps" % roundi(level * item.amount * 100)
		"love": return "+%.1f%% base value per tap" % (level * item.amount * 100)
		"cabrito": return "%.1f%% chance of double taps" % (critical_chance(level) * 100)
		"facetime": return "+%d base taps every 10th tap" % int(level * item.amount)
		"team": return "+%ds every workday" % int(level * item.amount)
		"playlist": return "+%.1fs every 50 taps" % (level * item.amount)
		"flights": return "%.1f%% ticket reduction" % ((1.0 - pow(1.0 - item.amount, level)) * 100)
		"jar": return "+%d%% savings at day-end" % roundi(interest_rate(level) * 100)
		"tips": return "+%d base taps at day-end" % int(level * item.amount)
	return item.description.get_slice("\n", 1)

func finish_shift() -> void:
	if phase != "work" or (remaining > 0 and money < goal()):
		return
	remaining = 0
	days += 1
	total_days += 1
	# Settle Willow first, then apply Princess once to the resulting savings.
	money += power("tips") * base_income() * global_multiplier()
	money *= 1.0 + interest_rate(count("jar"))
	if _complete_chapter():
		return
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
	if _complete_chapter():
		return
	offers = []
	set_phase("event" if pending_event else "transition")

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
		"discount": goal_multiplier *= 1.0 - item.amount

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
	if not _complete_chapter():
		set_phase("transition")

func _complete_chapter() -> bool:
	# Workdays settle once at timer expiry or immediately upon reaching the goal.
	if phase not in ["work", "ready", "transition", "upgrades", "event"] or days <= 0 or money < goal() or chapter in completed_chapters:
		return false
	if phase == "work" and remaining > 0:
		return false
	offers = []
	event_id = ""
	pending_event = false
	remaining = 0
	if chapter not in completed_chapters:
		completed_chapters.append(chapter)
		chapter_days.append(days)
	if chapter == 2:
		complete = true
		record_completed_run()
	set_phase("story")
	return true

func record_completed_run() -> void:
	if not complete or chapter != 2 or completed_chapters.size() != 3 or total_days <= 0:
		return
	if run_attempt <= 0:
		run_attempt = SaveManager.results.begin_attempt()
	if not SaveManager.results.has_recorded(run_attempt):
		var counts: Array = chapter_days if chapter_days.size() == 3 else []
		run_new_best = SaveManager.results.record_run(run_attempt, total_days, counts, Time.get_datetime_string_from_system(true) + "Z")
	elif SaveManager.results.last_error != OK:
		SaveManager.results.save_data()

func finish_story() -> void:
	if phase != "story":
		return
	if chapter == 2:
		record_completed_run()
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
	nicky_growth = 0.0
	shift_clicks = 0
	offers = []
	if has_relic("kiss"):
		apply_upgrade(FlightCatalog.find_item(FlightCatalog.UPGRADES, "appointment"))
	set_phase("transition")

func snapshot() -> Dictionary:
	return {"game_version": 4, "run_attempt": run_attempt, "chapter_days": chapter_days.duplicate(), "run_new_best": run_new_best, "chapter": chapter, "money": money, "days": days, "total_days": total_days,
		"completed_chapters": completed_chapters.duplicate(), "complete": complete, "upgrades": upgrades.duplicate(),
		"relics": relics.duplicate(), "phase": phase, "offers": offers.duplicate(), "event_id": event_id,
		"goal_multiplier": goal_multiplier, "remaining": remaining, "shift_clicks": shift_clicks,
		"burst_clicks": burst_clicks, "pending_event": pending_event, "last_event_id": last_event_id, "nicky_growth": nicky_growth, "rng_state": str(rng.state)}

func persist() -> void:
	SaveManager.progression = snapshot()
	save_error = SaveManager.save_data() != OK

func restore(data: Dictionary) -> bool:
	if data.get("game_version") != 1 and data.get("game_version") != 2 and data.get("game_version") != 3 and data.get("game_version") != 4:
		return false
	run_attempt = int(safe_number(data.get("run_attempt"), 0, 2000000000))
	run_new_best = data.get("run_new_best", false) == true
	chapter_days = []
	var saved_days: Variant = data.get("chapter_days", [])
	if saved_days is Array:
		for value: Variant in saved_days.slice(0, 3):
			chapter_days.append(int(safe_number(value, 0, 100000)))
	chapter = clampi(int(data.get("chapter", 0)), 0, 2)
	money = safe_number(data.get("money"), 0, 1e12)
	days = int(safe_number(data.get("days"), 0, 100000))
	total_days = int(safe_number(data.get("total_days"), days, 300000))
	completed_chapters = []
	for value: Variant in data.get("completed_chapters", []) if data.get("completed_chapters") is Array else []:
		if (value is int or value is float) and value == int(value) and int(value) in [0, 1, 2] and int(value) not in completed_chapters:
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
	if phase not in ["ready", "transition", "work", "upgrades", "event", "story", "relic", "ending"]:
		phase = "ready"
	offers = []
	var catalog: Array = FlightCatalog.RELICS if phase == "relic" else FlightCatalog.UPGRADES
	for id: Variant in data.get("offers", []) if data.get("offers") is Array else []:
		if id is String and FlightCatalog.find_item(catalog, id) != null and id not in offers:
			offers.append(id)
	event_id = str(data.get("event_id", ""))
	if phase == "event" and FlightCatalog.find_item(FlightCatalog.EVENTS, event_id) == null:
		phase = "upgrades"
	goal_multiplier = pow(1.0 - FlightCatalog.find_item(FlightCatalog.UPGRADES, "flights").amount, count("flights"))
	remaining = safe_number(data.get("remaining"), 0, 1e12)
	shift_clicks = int(safe_number(data.get("shift_clicks"), 0, 100000))
	burst_clicks = int(safe_number(data.get("burst_clicks"), 0, balance.burst_cap))
	pending_event = data.get("pending_event", false) == true
	last_event_id = str(data.get("last_event_id", ""))
	nicky_growth = safe_number(data.get("nicky_growth"), 0, 1e12) if data.get("game_version") == 4 else 0.0
	# Store 64-bit RNG state as text so browser JSON never rounds it.
	var saved_rng: Variant = data.get("rng_state")
	if saved_rng is String and saved_rng.is_valid_int():
		rng.state = int(saved_rng)
	# Legacy Cabrito counted consumable refills, not permanent chance levels.
	if data.get("game_version") != 4 and count("cabrito") > 0:
		upgrades["cabrito"] = 1
	# v0.1 decisions are retained, but old shops become one mandatory free reward.
	# Move legacy events behind their unclaimed free reward, retaining the event ID.
	if data.get("game_version") == 1:
		pending_event = phase == "event"
		if pending_event:
			phase = "upgrades"
	# Pending decisions migrate to the current chapter-local three-day schedule.
	if phase in ["upgrades", "event"]:
		pending_event = days > 0 and days % maxi(1, balance.event_interval) == 0
		if not pending_event:
			event_id = ""
			if phase == "event":
				phase = "transition"
	if pending_event and FlightCatalog.find_item(FlightCatalog.EVENTS, event_id) == null:
		event_id = random_ids(FlightCatalog.EVENTS, 1, [last_event_id])[0]
	if phase == "upgrades":
		offers = offers.filter(func(id: String) -> bool:
			return eligible_upgrade(FlightCatalog.find_item(FlightCatalog.UPGRADES, id)))
		if offers.is_empty():
			offers = upgrade_offers()
		if offers.is_empty():
			phase = "event" if pending_event else "transition"
	# No gameplay extension cap: validate against time actually earned by taps.
	var earned_time := floorf(float(shift_clicks) / balance.music_tap_interval) * power("playlist")
	remaining = minf(remaining, balance.shift_seconds + fixed_extension() + earned_time)
	save_clock = 0
	if phase == "work" and money >= goal():
		finish_shift()
	# Older saves may be waiting for a manual trip after a settled workday.
	if phase in ["ready", "upgrades", "event", "transition"]:
		_complete_chapter()
	if phase == "ready":
		phase = "transition"
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
