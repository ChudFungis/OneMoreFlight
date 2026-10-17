extends Node
## No dependencies. Save isolation is installed before any game action.
var failures: int = 0
var checks: int = 0
var saved_settings: Dictionary
var main: Node

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")

func item(id: String) -> FlightDefinition:
	return FlightCatalog.find_item(FlightCatalog.UPGRADES, id)

func run_checks() -> void:
	get_tree().root.size = Vector2i(390, 844)
	saved_settings = SaveManager.settings.duplicate(true)
	SaveManager.save_path = "/tmp/one_more_flight_tests.json"
	FlightStyle.preference_path = "/tmp/one_more_flight_presentation_tests.cfg"
	GameManager.set_process(false)
	# Load retained scripts inside the project runtime so autoloads are present.
	for path: String in ["res://scripts/ui/game.gd", "res://scripts/ui/menu.gd", "res://scripts/ui/settings.gd"]:
		var script := load(path) as Script
		check(script != null and script.can_instantiate(), "Retained script does not compile: " + path)
	main = preload("res://scenes/main.tscn").instantiate()
	add_child(main)
	check(SceneManager.screen_host.get_child(0).view == "main_menu", "Main menu missing")
	await capture_view("main_menu", 390)
	GameManager.new_game()
	check(GameManager.phase == "ready" and GameManager.money == 0, "New game did not reset")
	GameManager.start_shift()
	check(is_equal_approx(GameManager.remaining, 10), "Shift length incorrect")
	check(is_equal_approx(GameManager.tap(), 5), "Base income incorrect")
	SceneManager.pause_run()
	var before := GameManager.remaining
	GameManager.advance_time(2)
	check(GameManager.tap() == 0 and GameManager.remaining == before, "Pause changed gameplay")
	SceneManager.open_settings()
	SceneManager.close_settings()
	check(get_tree().paused and SceneManager.overlay_host.get_child(0).view == "pause_menu", "Settings lost pause context")
	SceneManager.resume_run()
	GameManager.apply_upgrade(item("cabrito"))
	check(GameManager.tap() == 10 and GameManager.burst_clicks == 19, "Cabrito effect failed")
	GameManager.burst_clicks = 0
	GameManager.upgrades = {}
	GameManager.apply_upgrade(item("facetime"))
	GameManager.relics = ["unlimited"]
	GameManager.shift_clicks = 9
	check(GameManager.tap() == 75, "FaceTime / relic synergy failed")
	GameManager.upgrades = {}
	GameManager.relics = []
	GameManager.apply_upgrade(item("love"))
	GameManager.apply_upgrade(item("appointment"))
	GameManager.combo = 5
	GameManager.since_tap = 0.1
	check(is_equal_approx(GameManager.tap(), 10.0), "Combo / appointment synergy failed")
	GameManager.since_tap = 2
	check(is_equal_approx(GameManager.tap(), 6.875), "Combo did not reset after delay")
	GameManager.upgrades = {}
	GameManager.money = 0
	GameManager.apply_upgrade(item("empire"))
	GameManager.apply_upgrade(item("team"))
	GameManager.money = 0
	GameManager.advance_time(1)
	check(is_equal_approx(GameManager.money, 5), "Passive / besties synergy failed")
	GameManager.apply_upgrade(item("playlist"))
	GameManager.shift_clicks = 4
	before = GameManager.remaining
	GameManager.tap()
	check(is_equal_approx(GameManager.remaining, before + 0.5), "Playlist extension failed")
	GameManager.upgrades = {}
	GameManager.remaining = 0.1
	GameManager.advance_time(0.1)
	check(GameManager.days == 1 and GameManager.phase == "upgrades", "Timer did not end workday exactly once")
	GameManager.advance_time(10)
	check(GameManager.days == 1, "Timer completed twice")
	check(GameManager.offers.size() == 3, "Expected 3 upgrade offers")
	GameManager.money = 0
	check(not GameManager.buy_trip(), "Travel bypassed mandatory reward")
	GameManager.next_day()
	check(GameManager.phase == "upgrades", "Reward could be skipped")
	GameManager.money = 1000
	var reward_money := GameManager.money
	var id: String = GameManager.offers[0]
	check(GameManager.buy_upgrade(id) and GameManager.count(id) > 0, "Purchase failed")
	check(not GameManager.buy_upgrade(id), "Offer purchased twice")
	check(GameManager.money == reward_money, "Free reward changed savings")
	GameManager.upgrades = {}
	GameManager.burst_clicks = 0
	GameManager.goal_multiplier = 1
	GameManager.phase = "ready"
	GameManager.apply_upgrade(item("cafecito"))
	GameManager.start_shift()
	check(is_equal_approx(GameManager.remaining, 12), "Coffee duration failed")
	GameManager.apply_upgrade(item("flights"))
	check(is_equal_approx(GameManager.goal(), 2100 * 0.92), "Ticket discount failed")
	GameManager.relics = ["passport"]
	check(is_equal_approx(GameManager.goal(), 2100 * 0.92 * 0.88), "Passport discount synergy failed")
	GameManager.relics = ["hoodie", "bracelet"]
	GameManager.shift_clicks = 0
	check(is_equal_approx(GameManager.tap(), 5 * 1.5 * 1.15), "Hoodie / bracelet earnings failed")
	GameManager.relics = []
	GameManager.apply_upgrade(item("tips"))
	GameManager.shift_clicks = 6
	check(is_equal_approx(GameManager.tap(), 30), "Seventh-tap tip failed")
	GameManager.upgrades = {}
	GameManager.apply_upgrade(item("jar"))
	GameManager.money = 100
	GameManager.finish_shift()
	check(is_equal_approx(GameManager.money, 102), "Interest failed")
	GameManager.phase = "ready"
	GameManager.money = 0
	check(not GameManager.buy_trip(), "Unaffordable trip accepted")
	SaveManager.settings["music_volume"] = 0.23
	SaveManager.settings["sfx_volume"] = 0.0
	AudioManager.apply_settings()
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "Zero SFX volume did not mute")
	SaveManager.save_data()
	SaveManager.settings["music_volume"] = 1.0
	SaveManager.load_data()
	check(is_equal_approx(SaveManager.settings["music_volume"], 0.23), "Audio settings did not persist")
	# Every event and alternate is resolvable without entering active clicking.
	for event: FlightDefinition in FlightCatalog.EVENTS:
		for alternate: bool in [false, true]:
			GameManager.phase = "event"
			GameManager.event_id = event.id
			GameManager.money = 1000
			GameManager.resolve_event(alternate)
			check(GameManager.phase == "ready" and GameManager.money >= 1000, "Event failed: " + event.id)
	await check_redesign()
	# Save/load preserves the exact decision and offers, not just a chapter index.
	GameManager.phase = "relic"
	GameManager.offers = ["kiss", "hoodie", "passport"]
	GameManager.persist()
	var expected := GameManager.snapshot()
	GameManager.money = 0
	SaveManager.progression = {}
	SaveManager.load_data()
	check(GameManager.restore(SaveManager.progression), "Save restoration rejected")
	var actual := GameManager.snapshot()
	for key: String in expected:
		if expected[key] is float:
			check(is_equal_approx(float(actual[key]), float(expected[key])), "Save numeric mismatch: " + key)
		else:
			check(actual[key] == expected[key], "Save round trip mismatch: " + key)
	GameManager.choose_relic("kiss")
	check(GameManager.chapter == 1 and GameManager.money == 0 and GameManager.relics.has("kiss"), "Relic transition failed")
	check(GameManager.upgrades.size() == 1 and GameManager.count("appointment") == 1, "Ordinary upgrade reset / free-upgrade relic failed")
	check(GameManager.days == 0 and GameManager.last_event_id == "", "Chapter event schedule did not reset")
	for day: int in [1, 2]:
		GameManager.start_shift()
		GameManager.advance_time(100)
		GameManager.buy_upgrade(GameManager.offers[0])
		check(GameManager.phase == ("event" if day == 2 else "ready"), "New chapter event cadence failed")
		if day == 2:
			GameManager.resolve_event()
	await check_presentation()
	await capture_decisions()
	# Deterministic complete games at different tapping rates, using real timers/income.
	for rate: int in [2, 3, 4]:
		await simulate_game(rate)
	GameManager.main_menu()
	GameManager.continue_game()
	check(GameManager.phase == "ending" and GameManager.complete, "Completed save cannot continue")
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await get_tree().create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/one_more_flight_ending.png")
	GameManager.new_game()
	GameManager.start_shift()
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await get_tree().create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/one_more_flight_game.png")
	check(get_viewport().get_visible_rect().size.x <= 400, "Portrait viewport not configured")
	var file := FileAccess.open(SaveManager.save_path, FileAccess.WRITE)
	file.store_string("not json")
	file.close()
	SaveManager.load_data()
	check(SaveManager.settings.has("music_volume"), "Corrupt save destroyed settings")
	DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.settings = saved_settings
	print("One More Flight: %d checks, %d failures" % [checks, failures])
	get_tree().quit(failures)

func simulate_game(rate: int) -> void:
	GameManager.new_game()
	GameManager.rng.seed = 12345
	var chapter_days: Array = []
	var work_seconds: float = 0
	var guard: int = 0
	while GameManager.phase != "ending" and guard < 150:
		guard += 1
		match GameManager.phase:
			"ready":
				if GameManager.money >= GameManager.goal():
					chapter_days.append(GameManager.days)
					check(GameManager.buy_trip(), "Earned trip could not be purchased")
				else:
					GameManager.start_shift()
			"work":
				while GameManager.phase == "work":
					GameManager.tap()
					var before_step := GameManager.remaining
					GameManager.advance_time(1.0 / rate)
					work_seconds += minf(1.0 / rate, before_step)
			"event": GameManager.resolve_event(true)
			"upgrades":
				var chosen: String = GameManager.offers[0]
				for preferred: String in ["facetime", "tips", "love", "appointment", "empire", "cafecito", "flights"]:
					if preferred in GameManager.offers:
						chosen = preferred
						break
				check(GameManager.buy_upgrade(chosen), "Required reward failed in simulation")
			"story": GameManager.finish_story()
			"relic": GameManager.choose_relic(GameManager.offers[0])
		await get_tree().process_frame
	check(GameManager.complete and GameManager.completed_chapters.size() == 3 and GameManager.relics.size() == 2, "Full game not reachable at %d taps/sec" % rate)
	print("Balance simulation %d taps/sec: days %s, working %.1fs" % [rate, chapter_days, work_seconds])

func check_redesign() -> void:
	GameManager.new_game()
	GameManager.rng.seed = 90210
	var first := GameManager.upgrade_offers()
	check(first.size() == 3, "First player needs three new choices")
	for id: String in first:
		check(GameManager.count(id) == 0, "First offer is not new")
	GameManager.apply_upgrade(item("appointment"))
	GameManager.phase = "upgrades"
	GameManager.offers = ["appointment"]
	check(GameManager.buy_upgrade("appointment") and GameManager.count("appointment") == 2, "Owned ability did not level")
	GameManager.apply_upgrade(item("appointment"))
	GameManager.apply_upgrade(item("appointment"))
	check(not GameManager.eligible_upgrade(item("appointment")), "Maximum level still eligible")
	GameManager.apply_upgrade(item("appointment"))
	check(GameManager.count("appointment") == 4, "Direct grants exceeded cap")
	GameManager.upgrades = {"appointment": 1, "facetime": 1, "tips": 1}
	var fresh_count := 0
	for trial: int in range(10000):
		var offer := GameManager.upgrade_offers()
		if GameManager.count(offer[0]) == 0:
			fresh_count += 1
		check(offer.size() == 3 and offer[0] != offer[1] and offer[1] != offer[2] and offer[0] != offer[2], "Duplicate offer")
	check(fresh_count > 6300 and fresh_count < 6700, "65/35 category weighting outside tolerance")
	print("New-category first-card frequency: %d/10000" % fresh_count)
	GameManager.upgrades = {}
	for definition: FlightDefinition in FlightCatalog.UPGRADES:
		GameManager.upgrades[definition.id] = definition.max_level
	GameManager.burst_clicks = 60
	check(GameManager.upgrade_offers().is_empty(), "Exhausted rewards still offered")
	GameManager.phase = "work"
	GameManager.days = 1
	GameManager.finish_shift()
	check(GameManager.phase == "event", "Exhausted rewards blocked required event")
	GameManager.resolve_event()
	GameManager.burst_clicks = 40
	check(GameManager.upgrade_offers() == ["cabrito"], "Single-category fallback failed")
	GameManager.apply_upgrade(item("cabrito"))
	check(GameManager.burst_clicks == 60, "Burst charge cap failed")
	GameManager.upgrades = {}
	GameManager.burst_clicks = 0
	GameManager.apply_upgrade(item("cafecito"))
	GameManager.apply_upgrade(item("cafecito"))
	GameManager.apply_upgrade(item("team"))
	GameManager.apply_upgrade(item("playlist"))
	GameManager.phase = "ready"
	GameManager.start_shift()
	check(GameManager.remaining == 16, "Shared fixed extension cap failed")
	GameManager.shift_clicks = 4
	GameManager.tap()
	check(GameManager.remaining == 16 and GameManager.extension_used == 0, "Music exceeded shared cap")
	GameManager.upgrades = {"playlist": 4, "empire": 1}
	GameManager.phase = "ready"
	GameManager.start_shift()
	GameManager.shift_clicks = 4
	GameManager.tap()
	check(GameManager.remaining == 12 and GameManager.extension_used == 2, "Music daily cap failed")
	var timed := GameManager.snapshot()
	GameManager.advance_time(1)
	check(GameManager.restore(timed) and GameManager.remaining == 12 and GameManager.extension_used == 2, "Workday restore changed time budget")
	GameManager.shift_clicks = 9
	GameManager.tap()
	check(GameManager.remaining == 12, "Loaded music budget paid twice")
	GameManager.money = 0
	GameManager.advance_time(100)
	check(GameManager.money == 60, "Passive earnings used time beyond shift")
	# Day scheduling, mandatory order, disk round trips and duplicate actions.
	GameManager.new_game()
	for day: int in range(1, 9):
		GameManager.start_shift()
		GameManager.advance_time(100)
		check(GameManager.days == day and GameManager.phase == "upgrades", "Reward not first")
		var saved := GameManager.snapshot()
		check(GameManager.restore(saved) and GameManager.snapshot() == saved, "Pending reward changed on load")
		var previous := GameManager.last_event_id
		GameManager.buy_upgrade(GameManager.offers[0])
		check(GameManager.phase == ("event" if day % 2 == 0 else "ready"), "Wrong event day")
		if day % 2 == 0:
			check(GameManager.event_id != previous, "Consecutive event repeated")
			GameManager.persist()
			SaveManager.load_data()
			check(GameManager.restore(SaveManager.progression) and GameManager.phase == "event", "Pending event lost on disk")
			GameManager.resolve_event()
			var paid := GameManager.money
			GameManager.resolve_event()
			check(GameManager.money == paid and GameManager.phase == "ready", "Event paid twice")
	# All positive outcomes, with exact amplifier and charge rounding.
	for event: FlightDefinition in FlightCatalog.EVENTS:
		for alternate: bool in [false, true]:
			GameManager.upgrades = {"blessing": 2}
			GameManager.relics = ["bracelet"]
			GameManager.money = 100
			GameManager.burst_clicks = 0
			GameManager.phase = "event"
			GameManager.event_id = event.id
			var effect := event.alternative_effect if alternate else event.effect
			var amount := event.alternative_amount if alternate else event.amount
			GameManager.resolve_event(alternate)
			if effect == "gift":
				check(is_equal_approx(GameManager.money, 100 + amount * 1.5 * 5 * 1.15), "Event gift/amplifier failed: " + event.id)
			else:
				check(GameManager.money == 100 and GameManager.burst_clicks == int(ceilf(amount * 1.5)), "Event burst/amplifier failed: " + event.id)
	# Safe legacy migration retains campaign, IDs, relics and decision.
	var legacy := GameManager.snapshot()
	legacy.game_version = 1
	legacy.phase = "work"
	legacy.remaining = 27
	legacy.upgrades = {"appointment": 99, "team": 1, "cafecito": 99}
	legacy.burst_clicks = 200
	legacy.shields = 3
	check(GameManager.restore(legacy), "Legacy save rejected")
	check(GameManager.remaining <= 16 and GameManager.count("appointment") == 4 and GameManager.burst_clicks == 60, "Legacy bounds migration failed")
	legacy.phase = "upgrades"
	legacy.offers = ["appointment", "facetime", "tips"]
	check(GameManager.restore(legacy) and GameManager.offers == ["facetime", "tips"], "Legacy shop migration failed")
	legacy.phase = "event"
	legacy.event_id = "repair"
	GameManager.restore(legacy)
	check(GameManager.phase == "upgrades" and GameManager.event_id == "repair", "Legacy event did not move behind reward")
	GameManager.buy_upgrade(GameManager.offers[0])
	GameManager.resolve_event()
	check(GameManager.phase == "ready", "Legacy event did not resolve once")
	await get_tree().process_frame

func capture_decisions() -> void:
	for width: int in [390, 360, 320, 430, 1024]:
		get_tree().root.size = Vector2i(width, 844)
		GameManager.new_game()
		await capture_view("ready", width)
		GameManager.start_shift()
		await capture_view("heart", width)
		GameManager.advance_time(100)
		# Show actual new and owned badges together.
		GameManager.upgrades = {"appointment": 1}
		GameManager.offers = ["appointment", "team", "playlist"]
		GameManager.set_phase("upgrades")
		await capture_view("rewards", width)
		var screen: FlightScreen = SceneManager.screen_host.get_child(0)
		screen.select_choice("appointment")
		await capture_view("selected", width)
		GameManager.pending_event = true
		GameManager.event_id = "repair"
		GameManager.buy_upgrade("appointment")
		await capture_view("event", width)
		GameManager.resolve_event()
		GameManager.money = GameManager.goal()
		GameManager.buy_trip()
		await capture_view("story", width)
		GameManager.finish_story()
		await capture_view("relics", width)
	get_tree().root.size = Vector2i(390, 844)

func capture_view(label: String, width: int) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var screen: Control = SceneManager.screen_host.get_child(0)
	var scroll: ScrollContainer = screen.get_child(1)
	check(screen.body.size.x <= screen.size.x - 40, "Content exceeds portrait width")
	if label in ["rewards", "relics"]:
		check(screen.selection_cards.size() == 3, "Three choices are not present")
		for card: Button in screen.selection_cards.values():
			check(card.get_global_rect().end.x <= screen.size.x, "Card exceeds viewport")
			check(card.get_global_rect().end.y <= screen.size.y, "Choice hidden below viewport")
			var row: BoxContainer = card.get_child(0).get_child(0)
			check(row.get_global_rect().end.y <= card.get_global_rect().end.y, "Card content spills outside border")
	check_buttons(screen)
	for child: Node in screen.get_children():
		if child.name == "Celebration":
			check(child.size.y <= 60, "Celebration obscures the screen")
	if DisplayServer.get_name() != "headless":
		await get_tree().create_timer(0.25).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/omf_%s_%d.png" % [label, width])
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/omf_%s_%d_bottom.png" % [label, width])

func check_buttons(node: Node) -> void:
	if node is Button:
		check(node.size.y >= 52, "Touch target too short")
	for child: Node in node.get_children():
		check_buttons(child)

func check_presentation() -> void:
	for entry: Array in [["upgrades", FlightCatalog.UPGRADES], ["events", FlightCatalog.EVENTS], ["relics", FlightCatalog.RELICS]]:
		for definition: FlightDefinition in entry[1]:
			check(ResourceLoader.exists("res://assets/art/%s/%s.svg" % [entry[0], definition.id]), "Placeholder missing: " + definition.id)
			check(FlightArt.texture(entry[0], definition.id) != null, "Artwork failed to resolve")
	check(FlightArt.texture("events", "missing_test_id") != null, "Missing art fallback failed")
	GameManager.new_game()
	GameManager.start_shift()
	await get_tree().process_frame
	await get_tree().process_frame
	var screen: FlightScreen = SceneManager.screen_host.get_child(0)
	var before_clicks := GameManager.shift_clicks
	var before_money := GameManager.money
	# Dispatch real GUI mouse down/up events, with touch represented by that same path.
	for index: int in range(30):
		var down := InputEventMouseButton.new()
		down.button_index = MOUSE_BUTTON_LEFT
		down.position = screen.tap_button.get_global_rect().get_center()
		down.pressed = true
		get_viewport().push_input(down, true)
		var up := down.duplicate() as InputEventMouseButton
		up.pressed = false
		get_viewport().push_input(up, true)
	check(GameManager.shift_clicks == before_clicks + 30, "Rapid GUI taps missed or doubled")
	check(GameManager.money == before_money + 150, "GUI tap payouts changed")
	check(screen.timer_label.text == "10.0 seconds", "Timer display does not match remaining time")
	check(screen.feedback_count >= 30 and screen.feedback_count <= 35, "Earnings feedback missing or particles excessive")
	GameManager.finish_shift()
	screen = SceneManager.screen_host.get_child(0)
	var id: String = GameManager.offers[0]
	var old_level := GameManager.count(id)
	var untouched := GameManager.snapshot()
	screen.select_choice(id)
	check(GameManager.snapshot() == untouched, "Highlight committed a reward prematurely")
	GameManager.persist()
	SaveManager.load_data()
	GameManager.restore(SaveManager.progression)
	screen.rebuild()
	check(screen.selected_id.is_empty() and GameManager.phase == "upgrades", "Restore lost required choice")
	screen.select_choice(id)
	screen.commit_choice()
	screen.commit_choice()
	check(GameManager.count(id) == old_level + 1 and GameManager.money == before_money + 150, "Confirmation duplicated or charged reward")
	FlightStyle.reduced_motion = true
	check(FlightStyle.save_preferences() == OK, "Motion preference save failed")
	FlightStyle.reduced_motion = false
	FlightStyle.load_preferences()
	check(FlightStyle.reduced_motion, "Motion preference restore failed")
	GameManager.start_shift()
	screen = SceneManager.screen_host.get_child(0)
	screen.animate_tap()
	screen.release_heart()
	check(screen.heart_image.scale == Vector2.ONE, "Reduced motion still scales heart")
	FlightStyle.reduced_motion = false
	DirAccess.remove_absolute(FlightStyle.preference_path)
	await get_tree().process_frame
