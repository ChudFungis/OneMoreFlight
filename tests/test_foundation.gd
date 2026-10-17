extends Node
## No dependencies. Save isolation is installed before any game action.
var failures: int = 0
var checks: int = 0
var saved_settings: Dictionary
var main: Node
var resume_ambient_pause: bool = false

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")

func _process(_delta: float) -> void:
	# Native visual tests may lose OS focus while the owner uses their computer.
	# Explicit pause tests leave this off; accelerated drivers emulate Resume.
	if resume_ambient_pause and GameManager.state == GameManager.State.PAUSED:
		print("Automated driver resumed an ambient focus pause")
		SceneManager.resume_run()

func item(id: String) -> FlightDefinition:
	return FlightCatalog.find_item(FlightCatalog.UPGRADES, id)

func run_checks() -> void:
	get_tree().root.size = Vector2i(390, 844)
	saved_settings = SaveManager.settings.duplicate(true)
	SaveManager.save_path = "/tmp/one_more_flight_tests.json"
	SaveManager.progression = {}
	SaveManager.results = FlightResults.new()
	SaveManager.results.save_path = "/tmp/one_more_flight_results_tests.json"
	DirAccess.remove_absolute(SaveManager.results.save_path)
	SaveManager.results.load_data()
	FlightStyle.preference_path = "/tmp/one_more_flight_presentation_tests.cfg"
	GameManager.set_process(false)
	# Load retained scripts inside the project runtime so autoloads are present.
	for path: String in ["res://scripts/ui/game.gd", "res://scripts/ui/menu.gd", "res://scripts/ui/settings.gd"]:
		var script := load(path) as Script
		check(script != null and script.can_instantiate(), "Retained script does not compile: " + path)
	main = preload("res://scenes/main.tscn").instantiate()
	add_child(main)
	check(SceneManager.screen_host.get_child(0).view == "main_menu", "Main menu missing")
	for font: FontVariation in [FlightStyle.FONT_MEDIUM, FlightStyle.FONT_SEMIBOLD, FlightStyle.FONT_BOLD, FlightStyle.FONT_HEADING]:
		var coordinates := TextServerManager.get_primary_interface().font_get_variation_coordinates(font.get_rids()[0])
		check(font.get_font_name() == "Baloo 2" and coordinates == font.variation_opentype, "Baloo weight is not applied to the rendered font")
	await capture_view("main_menu", 390)
	await check_home_results()
	await check_milestones()
	GameManager.new_game()
	check(GameManager.phase == "transition" and GameManager.money == 0, "New game did not reset")
	GameManager.start_shift()
	check(is_equal_approx(GameManager.remaining, 10), "Shift length incorrect")
	check(is_equal_approx(GameManager.tap(), 5), "Base income incorrect")
	SceneManager.pause_run()
	await capture_modal("pause")
	var before := GameManager.remaining
	GameManager.advance_time(2)
	check(GameManager.tap() == 0 and GameManager.remaining == before, "Pause changed gameplay")
	SceneManager.open_settings()
	await capture_modal("settings")
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
	check(GameManager.phase == "upgrades", "Below-goal workday did not offer a reward")
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
	GameManager.remaining = 0
	GameManager.finish_shift()
	check(is_equal_approx(GameManager.money, 102), "Interest failed")
	GameManager.phase = "ready"
	GameManager.money = 0
	check(GameManager.phase == "ready", "Below-goal state changed unexpectedly")
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
			check(GameManager.phase == "transition" and GameManager.money >= 1000, "Event failed: " + event.id)
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
	for day: int in [1, 2, 3]:
		GameManager.start_shift()
		GameManager.advance_time(100)
		GameManager.buy_upgrade(GameManager.offers[0])
		check(GameManager.phase == ("event" if day == 3 else "transition"), "New chapter event cadence failed")
		if day == 3:
			GameManager.resolve_event()
	await check_savings_hud()
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
	DirAccess.remove_absolute(SaveManager.results.save_path)
	DirAccess.remove_absolute(SaveManager.results.save_path + ".tmp")
	SaveManager.settings = saved_settings
	print("One More Flight: %d checks, %d failures" % [checks, failures])
	get_tree().quit(failures)

func simulate_game(rate: int) -> void:
	resume_ambient_pause = true
	GameManager.new_game()
	GameManager.rng.seed = 12345
	var chapter_days: Array = []
	var work_seconds: float = 0
	var guard: int = 0
	while GameManager.phase != "ending" and guard < 150:
		guard += 1
		match GameManager.phase:
			"ready", "transition": GameManager.start_shift()
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
			"story":
				chapter_days.append(GameManager.days)
				GameManager.finish_story()
			"relic": GameManager.choose_relic(GameManager.offers[0])
		await get_tree().process_frame
	check(GameManager.complete and GameManager.completed_chapters.size() == 3 and GameManager.relics.size() == 2, "Full game not reachable at %d taps/sec" % rate)
	check(GameManager.chapter_days == chapter_days, "Completed chapter counts differ from simulation")
	check(SaveManager.results.recent[0].total_days == GameManager.total_days, "Completed campaign result missing")
	print("Balance simulation %d taps/sec: days %s, working %.1fs" % [rate, chapter_days, work_seconds])
	resume_ambient_pause = false

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
	GameManager.days = 2
	GameManager.remaining = 0
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
		check(GameManager.phase == ("event" if day % 3 == 0 else "transition"), "Wrong event day")
		if day % 3 == 0:
			check(GameManager.event_id != previous, "Consecutive event repeated")
			GameManager.persist()
			SaveManager.load_data()
			check(GameManager.restore(SaveManager.progression) and GameManager.phase == "event", "Pending event lost on disk")
			GameManager.resolve_event()
			var paid := GameManager.money
			GameManager.resolve_event()
			check(GameManager.money == paid and GameManager.phase == "transition", "Event paid twice")
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
	legacy.days = 3
	legacy.event_id = "repair"
	GameManager.restore(legacy)
	check(GameManager.phase == "upgrades" and GameManager.event_id == "repair", "Legacy event did not move behind reward")
	GameManager.buy_upgrade(GameManager.offers[0])
	GameManager.resolve_event()
	check(GameManager.phase == "transition", "Legacy event did not resolve once")
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
		GameManager.days = 3 # Presentation fixture: an eligible completed event day.
		GameManager.total_days = 3
		GameManager.pending_event = true
		GameManager.event_id = "repair"
		GameManager.buy_upgrade("appointment")
		await capture_view("event", width)
		GameManager.resolve_event()
		GameManager.money = GameManager.goal()
		GameManager.start_shift()
		GameManager.advance_time(100)
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
	GameManager.remaining = 0
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

func finish_test_adventure(counts: Array) -> void:
	GameManager.new_game()
	for chapter_day_count: int in counts:
		GameManager.days = chapter_day_count - 1
		GameManager.total_days += chapter_day_count - 1
		GameManager.money = GameManager.goal()
		GameManager.start_shift()
		GameManager.advance_time(100)
		check(GameManager.phase == "story", "Milestone did not complete chapter")
		GameManager.finish_story()
		if GameManager.phase == "relic":
			GameManager.choose_relic(GameManager.offers[0])

func check_home_results() -> void:
	var results: FlightResults = SaveManager.results
	check(results.best.is_empty() and results.recent.is_empty(), "First launch contains completed records")
	var home: FlightScreen = SceneManager.screen_host.get_child(0)
	check(home.tap_button.get_child(0).texture == FlightArt.texture("heart", "tap"), "Home uses different heart art")
	# A home heart press starts fresh immediately; duplicate stale callbacks do not.
	home.start_adventure()
	var attempt := GameManager.run_attempt
	home.start_adventure()
	check(GameManager.run_attempt == attempt and GameManager.chapter == 0, "Home heart activated twice")
	GameManager.start_shift()
	GameManager.tap()
	GameManager.upgrades = {"appointment": 2}
	GameManager.relics = ["hoodie"]
	GameManager.burst_clicks = 20
	GameManager.main_menu()
	check(results.recent.is_empty(), "Unfinished run entered completed history")
	# Reload the active save and ledger, then boot the persistent hosts like a fresh launch.
	SaveManager.load_data()
	results.load_data()
	SceneManager.show_screen("main_menu")
	home = SceneManager.screen_host.get_child(0)
	home.tap_button.pressed.emit()
	check(GameManager.phase == "transition" and GameManager.days == 0 and GameManager.money == 0 and GameManager.upgrades.is_empty() and GameManager.relics.is_empty(), "Home restored unfinished progression")
	check(GameManager.burst_clicks == 0 and GameManager.offers.is_empty() and GameManager.event_id.is_empty() and GameManager.chapter_days.is_empty(), "Fresh run retained temporary state")
	finish_test_adventure([7, 7, 7])
	check(results.recent.size() == 1 and results.best.total_days == 21 and GameManager.run_new_best, "First completion not recorded as best")
	var completed := GameManager.snapshot()
	GameManager.persist()
	SaveManager.load_data()
	check(GameManager.restore(SaveManager.progression) and GameManager.completed_chapters.size() == 3, "Completed chapters lost on disk restore")
	GameManager.record_completed_run()
	GameManager.finish_story()
	GameManager.restore(completed)
	GameManager.record_completed_run()
	check(results.recent.size() == 1, "Ending revisit duplicated result")
	var loaded := FlightResults.new()
	loaded.save_path = results.save_path
	loaded.load_data()
	check(loaded.recent == results.recent and loaded.best == results.best, "Results did not survive disk reload")
	check(loaded.recent[0].chapter_days == [7, 7, 7] and not loaded.recent[0].completed_at.is_empty(), "Completed metadata missing")
	finish_test_adventure([6, 6, 6])
	var best_attempt: int = results.best.attempt
	check(results.best.total_days == 18 and GameManager.run_new_best, "Faster adventure failed to update best")
	for total: int in [24, 25, 26, 27, 28, 29]:
		finish_test_adventure([8, 8, total - 16])
		check(results.best.total_days == 18 and not GameManager.run_new_best, "Slower run replaced best")
	check(results.recent.size() == 5 and results.recent[0].total_days == 29 and results.recent[4].total_days == 25, "History order or five-result limit incorrect")
	check(results.best.attempt == best_attempt, "Best disappeared after leaving recent history")
	GameManager.restore(completed)
	GameManager.record_completed_run()
	check(results.recent.size() == 5 and results.recent[0].total_days == 29, "Expired historical run recorded twice")
	finish_test_adventure([6, 6, 6])
	check(results.best.attempt == best_attempt and not GameManager.run_new_best, "Tied score incorrectly beat best")
	results.load_data()
	check(results.best.total_days == 18 and results.recent[0].total_days == 18, "Best/tie lost on reload")
	GameManager.main_menu()
	home = SceneManager.screen_host.get_child(0)
	home.show_results()
	await capture_view("results", 390)
	home.show_home()
	# First launch, best/history, and small-screen home checks in the same persistent host.
	for dimensions: Vector2i in [Vector2i(320, 640), Vector2i(360, 640), Vector2i(390, 844), Vector2i(430, 932), Vector2i(1024, 768)]:
		get_tree().root.size = dimensions
		await capture_view("home_best", dimensions.x)
		check(home.body.get_combined_minimum_size().y + 56 <= home.size.y, "Home requires unnecessary vertical scrolling")
	get_tree().root.size = Vector2i(390, 844)
	# Missing and corrupt ledger content never creates a fake completed run.
	var scratch := FlightResults.new()
	scratch.save_path = "/tmp/one_more_flight_results_invalid_tests.json"
	DirAccess.remove_absolute(scratch.save_path)
	scratch.load_data()
	check(scratch.best.is_empty(), "Missing results generated a best")
	var file := FileAccess.open(scratch.save_path, FileAccess.WRITE)
	file.store_string("not json")
	file.close()
	scratch.load_data()
	check(scratch.recent.is_empty() and scratch.best.is_empty(), "Corrupt results generated completed runs")
	file = FileAccess.open(scratch.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 1, "recent": [null, {"attempt": -1, "total_days": 0}], "best": "invalid", "next_attempt": -5}))
	file.close()
	scratch.load_data()
	check(scratch.recent.is_empty() and scratch.best.is_empty() and scratch.next_attempt == 1, "Malformed results fields not validated")
	DirAccess.remove_absolute(scratch.save_path)
	GameManager.new_game()
	check(results.best.total_days == 18 and results.recent.size() == 5, "New adventure erased completed records")
	await get_tree().process_frame

func check_milestones() -> void:
	GameManager.new_game()
	var history_size := SaveManager.results.recent.size()
	var best_before := SaveManager.results.best.duplicate(true)
	for chapter_index: int in range(3):
		GameManager.apply_upgrade(item("flights"))
		GameManager.apply_upgrade(item("jar"))
		if chapter_index == 1:
			check(GameManager.has_relic("passport"), "Travel relic did not persist")
		GameManager.days = 2 # Complete on an event day: neither event nor reward may appear.
		GameManager.total_days = chapter_index * 3 + 2
		var target := GameManager.goal()
		GameManager.money = target / 1.02 - 1
		GameManager.start_shift()
		GameManager.tap()
		GameManager.money = target + 25
		var working := GameManager.snapshot()
		check(GameManager.restore(working) and GameManager.phase == "work", "Load completed a still-active workday")
		GameManager.money = target / 1.02 + (100 if chapter_index == 1 else 0)
		GameManager.finish_shift()
		check(GameManager.phase == "work" and GameManager.days == 2, "Workday completed before timer expired")
		GameManager.advance_time(GameManager.remaining - 0.1)
		check(GameManager.phase == "work", "Milestone interrupted tapping")
		GameManager.advance_time(0.1)
		check(GameManager.phase == "story" and GameManager.days == 3, "Settled interest did not trigger milestone")
		check(GameManager.offers.is_empty() and GameManager.event_id.is_empty() and not GameManager.pending_event, "Winning day showed upgrade/event")
		check(is_equal_approx(GameManager.money, target + (102 if chapter_index == 1 else 0)), "Milestone deducted savings or interest incorrect")
		var saved := GameManager.snapshot()
		GameManager.finish_shift()
		GameManager.advance_time(20)
		check(GameManager.snapshot() == saved, "Milestone triggered twice")
		SaveManager.load_data()
		check(GameManager.restore(SaveManager.progression) and GameManager.phase == "story", "Milestone story lost on disk reload")
		check(GameManager.completed_chapters.size() == chapter_index + 1 and GameManager.chapter_days.size() == chapter_index + 1, "Completion metadata duplicated on load")
		GameManager.finish_story()
		if chapter_index < 2:
			# Choose a known relic using the existing choice API.
			GameManager.offers = ["passport"] if chapter_index == 0 else ["kiss"]
			GameManager.choose_relic(GameManager.offers[0])
			check(GameManager.money == 0 and GameManager.days == 0 and GameManager.goal_multiplier == 1, "Excess savings carried into next chapter")
			check(GameManager.upgrades.is_empty() or GameManager.upgrades == {"appointment": 1}, "Chapter reset retained ordinary abilities")
	check(GameManager.phase == "ending" and GameManager.total_days == 9 and GameManager.complete, "Final automatic milestone did not finish")
	check(SaveManager.results.recent[0].total_days == 9 and SaveManager.results.recent[0].chapter_days == [3, 3, 3], "Final automatic completion recorded wrong score")
	check(GameManager.run_new_best and SaveManager.results.best.total_days == 9, "Automatic completion did not update personal best")
	check(SaveManager.results.recent.size() == mini(5, history_size + 1) and best_before.total_days > 9, "Completed ledger count incorrect")
	var recent := SaveManager.results.recent.duplicate(true)
	GameManager.record_completed_run()
	GameManager.restore(GameManager.snapshot())
	GameManager.record_completed_run()
	check(SaveManager.results.recent == recent, "Final score recorded twice")
	# A discounted goal or event gift can finish an already settled day too.
	GameManager.new_game()
	GameManager.days = 1
	GameManager.total_days = 1
	GameManager.money = GameManager.goal() * 0.95
	GameManager.phase = "upgrades"
	GameManager.offers = ["flights"]
	check(GameManager.buy_upgrade("flights") and GameManager.phase == "story", "Discount did not auto-complete settled day")
	GameManager.new_game()
	GameManager.days = 2
	GameManager.total_days = 2
	GameManager.money = GameManager.goal() - 1
	GameManager.phase = "event"
	GameManager.event_id = "call"
	GameManager.resolve_event()
	check(GameManager.phase == "story", "Event gift did not auto-complete settled day")
	# Old manual-purchase saves with a reached milestone must not be stranded.
	GameManager.new_game()
	var legacy := GameManager.snapshot()
	legacy.days = 2
	legacy.total_days = 2
	legacy.money = GameManager.goal() + 100
	for pending: String in ["ready", "upgrades", "event"]:
		legacy.phase = pending
		legacy.offers = ["appointment", "love", "tips"]
		legacy.event_id = "call"
		check(GameManager.restore(legacy) and GameManager.phase == "story" and GameManager.days == 2, "Reached legacy milestone did not resume story")
	await check_collection_ui()
	await check_seamless_flow()

func collect_labels(node: Node) -> String:
	var text: String = node.text + "\n" if node is Label else ""
	for child: Node in node.get_children():
		text += collect_labels(child)
	return text

func check_collection_ui() -> void:
	GameManager.new_game()
	var empty_screen: FlightScreen = SceneManager.screen_host.get_child(0)
	check(empty_screen.item_rows.is_empty() and not collect_labels(empty_screen.item_lists).contains("None yet"), "Empty suitcase leaked a list row")
	await capture_view("suitcase_empty", 390)
	GameManager.start_shift()
	GameManager.advance_time(100)
	var earned_id: String = GameManager.offers[0]
	GameManager.buy_upgrade(earned_id)
	check(empty_screen.item_rows.size() == 1 and empty_screen.item_rows.has("upgrades/" + earned_id), "Earned ability did not enter suitcase")
	check((empty_screen.item_lists as FlightSuitcase).fresh_items.has("upgrades/" + earned_id), "New collectible did not receive entrance feedback")
	await capture_view("suitcase_ability", 390)
	GameManager.upgrades = {}
	GameManager.relics = ["passport"]
	GameManager.set_phase("ready")
	check(empty_screen.item_rows.size() == 1 and empty_screen.item_rows.has("relics/passport"), "Keepsake-only suitcase incorrect")
	await capture_view("suitcase_keepsake", 390)
	GameManager.new_game()
	GameManager.upgrades = {"flights": 1, "tips": 2, "love": 3}
	GameManager.relics = ["bracelet", "passport"]
	GameManager.set_phase("ready")
	var screen: FlightScreen = SceneManager.screen_host.get_child(0)
	check(screen.item_lists.visible and screen.item_rows.size() == 5, "Collected items are not always visible")
	var inline_text := collect_labels(screen.item_lists)
	check(not inline_text.contains("Abilities") and not inline_text.contains("Keepsakes") and not inline_text.contains("Nicky Mode"), "Text inventory leaked into suitcase")
	check(not inline_text.contains("Bonuses:") and not inline_text.contains("per level"), "Detailed effects leaked into inline list")
	await capture_view("collection", 390)
	get_tree().root.size = Vector2i(360, 844)
	await capture_view("collection", 360)
	var saved_keys: Array = screen.item_rows.keys()
	GameManager.persist()
	SaveManager.load_data()
	check(GameManager.restore(SaveManager.progression), "Suitcase fixture did not restore")
	check(screen.item_rows.size() == 5 and screen.item_rows.keys() == saved_keys, "Save/load lost or duplicated collection icons")
	var before := GameManager.snapshot()
	screen.item_rows["upgrades/love"].pressed.emit()
	var modal: FlightItemDetails = SceneManager.overlay_host.get_child(0)
	check(modal.item.id == "love" and modal.level == 3, "Item tap opened incorrect detail")
	var text := collect_labels(modal)
	check(text.contains("Level 3 / 3") and text.contains(item("love").description.get_slice("\n", 0)) and text.contains(item("love").description.get_slice("\n", 1)), "Detail omitted level, flavor, or exact effect")
	check(GameManager.snapshot() == before, "Opening detail changed campaign/save state")
	await capture_modal("ability_popup")
	modal.close()
	await get_tree().process_frame
	screen.item_rows["relics/bracelet"].pressed.emit()
	modal = SceneManager.overlay_host.get_child(0)
	check(modal.is_relic and collect_labels(modal).contains("Permanent keepsake"), "Keepsake details missing")
	await capture_modal("keepsake_popup")
	var escape := InputEventAction.new()
	escape.action = "ui_cancel"
	escape.pressed = true
	get_viewport().push_input(escape, true)
	await get_tree().process_frame
	check(SceneManager.overlay_host.get_child_count() == 0 and GameManager.state == GameManager.State.PLAYING, "Closing detail opened pause or left an overlay")
	# Real-time processing is suspended locally, then restored without a save action.
	GameManager.start_shift()
	GameManager.set_process(true)
	screen.show_item_details(item("flights"), false)
	var remaining := GameManager.remaining
	await get_tree().create_timer(0.1).timeout
	check(GameManager.remaining == remaining, "Workday clock ran behind detail panel")
	modal = SceneManager.overlay_host.get_child(0)
	modal.close()
	await get_tree().process_frame
	check(GameManager.is_processing(), "Closing detail did not restore workday processing")
	screen.show_item_details(item("flights"), false)
	SceneManager.pause_run()
	check(get_tree().paused and GameManager.is_processing() and SceneManager.overlay_host.get_child(0).view == "pause_menu", "Detail interrupted normal Pause/Save handling")
	SceneManager.resume_run()
	GameManager.set_process(false)
	# Stress layout with the entire catalog; data/rules remain untouched.
	for definition: FlightDefinition in FlightCatalog.UPGRADES:
		GameManager.upgrades[definition.id] = 1
	GameManager.relics = []
	for definition: FlightDefinition in FlightCatalog.RELICS:
		GameManager.relics.append(definition.id)
	GameManager.set_phase("ready")
	await capture_view("collection_full", 360)
	check(screen.item_rows.size() == FlightCatalog.UPGRADES.size() + FlightCatalog.RELICS.size(), "Suitcase duplicated or omitted catalog items")
	var suitcase := screen.item_lists as FlightSuitcase
	check(suitcase.scroll.size.y <= 128 and suitcase.contents.size.y > suitcase.scroll.size.y, "Large suitcase did not use compact scroll overflow")
	suitcase.scroll.scroll_vertical = int(suitcase.scroll.get_v_scroll_bar().max_value)
	await get_tree().process_frame
	await capture_modal_if_suitcase(screen)

	for row: Button in screen.item_rows.values():
		check(row.size.y >= 52 and row.get_global_rect().end.x <= screen.size.x, "Collection row clips or has a small touch target")
	for definition: FlightDefinition in FlightCatalog.UPGRADES:
		screen.show_item_details(definition, false)
		modal = SceneManager.overlay_host.get_child(0)
		check(collect_labels(modal).contains(definition.description.get_slice("\n", 1)), "Ability detail missing effect: " + definition.id)
		modal.close()
		await get_tree().process_frame
	get_tree().root.size = Vector2i(390, 844)

func capture_modal(label: String) -> void:
	await get_tree().create_timer(0.25, true).timeout
	await get_tree().process_frame
	await get_tree().process_frame
	check_buttons(SceneManager.overlay_host)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/omf_%s.png" % label)

func check_seamless_flow() -> void:
	GameManager.new_game()
	GameManager.rng.seed = 202633
	# Deterministic rules use the same start/advance/tap methods; UI arms separately.
	for day: int in range(1, 10):
		check(GameManager.phase == "transition", "Decision returned to overview")
		var idle_money := GameManager.money
		GameManager.advance_time(5)
		check(GameManager.money == idle_money and GameManager.tap() == 0, "Transition awarded earnings")
		GameManager.start_shift()
		GameManager.start_shift()
		check(GameManager.days == day - 1, "Transition started/counts workday twice")
		GameManager.advance_time(GameManager.remaining)
		check(GameManager.phase == "upgrades" and GameManager.days == day, "Workday did not produce one reward")
		var id: String = GameManager.offers[0]
		GameManager.buy_upgrade(id)
		check(not GameManager.buy_upgrade(id), "Double reward during transition")
		check(GameManager.phase == ("event" if day % 3 == 0 else "transition"), "Three-day schedule incorrect")
		if day % 3 == 0:
			var event := GameManager.event_id
			GameManager.persist()
			SaveManager.load_data()
			check(GameManager.restore(SaveManager.progression) and GameManager.event_id == event, "Event rerolled on reload")
			GameManager.resolve_event(true)
			var charges := GameManager.burst_clicks
			GameManager.resolve_event(true)
			check(GameManager.phase == "transition" and GameManager.burst_clicks == charges, "Event paid twice")
		# Keep this scheduling test below goals, independently of reward RNG.
		GameManager.money = 0
	# Restoring a pending transition cannot replay decisions or start the timer early.
	var pending := GameManager.snapshot()
	GameManager.persist()
	SaveManager.load_data()
	check(GameManager.restore(SaveManager.progression) and GameManager.snapshot() == pending, "Transition round trip changed campaign")
	# Old even-day pending events migrate away; third-day events stay queued.
	var old := pending.duplicate(true)
	old.game_version = 2
	old.phase = "event"
	old.days = 2
	old.event_id = "call"
	check(GameManager.restore(old) and GameManager.phase == "transition" and not GameManager.pending_event, "Old even-day event survived migration")
	old.days = 3
	check(GameManager.restore(old) and GameManager.phase == "event" and GameManager.event_id == "call", "Eligible legacy event lost")
	# Six settled days in each chapter: Day 3 event, Day 6 milestone priority.
	GameManager.new_game()
	for chapter_index: int in range(3):
		for day: int in range(1, 7):
			GameManager.start_shift()
			GameManager.money = GameManager.goal() if day == 6 else 0
			GameManager.advance_time(GameManager.remaining)
			if day == 6:
				check(GameManager.phase == "story" and not GameManager.pending_event and GameManager.offers.is_empty(), "Day 6 milestone failed to suppress event/reward")
			else:
				var selected: String = GameManager.offers[0]
				GameManager.buy_upgrade(selected)
				check(GameManager.phase == ("event" if day == 3 else "transition"), "Chapter-local event schedule did not reset")
				if day == 3:
					GameManager.resolve_event(true)
		GameManager.finish_story()
		if chapter_index < 2:
			GameManager.choose_relic(GameManager.offers[0])
			check(GameManager.phase == "transition" and GameManager.days == 0 and not GameManager.pending_event and GameManager.event_id.is_empty(), "New chapter retained scheduled event/day")
	check(GameManager.phase == "ending" and GameManager.total_days == 18 and SaveManager.results.recent[0].chapter_days == [6, 6, 6], "Seamless final result has incorrect day counts")
	# Temporary charges persist, while per-shift feedback/time budgets reset.
	GameManager.new_game()
	GameManager.start_shift()
	GameManager.advance_time(GameManager.remaining)
	GameManager.offers = ["cabrito"]
	GameManager.buy_upgrade("cabrito")
	var kept_charges := GameManager.burst_clicks
	GameManager.combo = 5
	GameManager.extension_used = 2
	GameManager.start_shift()
	check(GameManager.burst_clicks == kept_charges and GameManager.combo == 0 and GameManager.extension_used == 0 and GameManager.remaining == 10, "Automatic next shift changed temporary-bonus reset rules")
	# Pause during the handoff retains the full next workday.
	GameManager.new_game()
	GameManager.set_process(true)
	SceneManager.pause_run()
	await get_tree().create_timer(0.5).timeout
	check(GameManager.phase == "transition" and GameManager.remaining == 0, "Paused transition consumed workday time")
	SceneManager.resume_run()
	resume_ambient_pause = true
	await get_tree().create_timer(0.5).timeout
	check(GameManager.phase == "work" and GameManager.remaining > 9.7, "Transition did not resume with a full workday")
	GameManager.set_process(false)
	# Actual UI handshake: render first, wait, reject held input, then start exactly once.
	resume_ambient_pause = true
	GameManager.new_game()
	var screen: FlightScreen = SceneManager.screen_host.get_child(0)
	GameManager.set_process(true)
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = screen.tap_button.get_global_rect().get_center()
	down.pressed = true
	Input.parse_input_event(down)
	await get_tree().create_timer(0.5).timeout
	check(GameManager.phase == "transition" and GameManager.remaining == 0 and GameManager.shift_clicks == 0, "Held input leaked through transition")
	var up := down.duplicate() as InputEventMouseButton
	up.pressed = false
	Input.parse_input_event(up)
	await get_tree().create_timer(0.08).timeout
	check(GameManager.phase == "work" and GameManager.remaining > 9.8 and GameManager.shift_clicks == 0, "Visible-screen handshake failed or release earned money")
	check(screen.body.modulate.a == 1 and not screen.tap_button.disabled, "Timer started before screen was visible/input-ready")
	GameManager.set_process(false)
	# Check UI-driven upgrade -> transition -> next workday, with no start action.
	GameManager.advance_time(GameManager.remaining)
	var chosen: String = GameManager.offers[0]
	screen.select_choice(chosen)
	screen.commit_choice()
	GameManager.set_process(true)
	await get_tree().create_timer(0.2).timeout
	check(GameManager.phase == "transition" and GameManager.remaining == 0, "Workday started during fade")
	screen.rebuild()
	await get_tree().create_timer(0.25).timeout
	check(GameManager.phase == "transition", "Stale transition callback armed a rebuilt screen")
	await get_tree().create_timer(0.25).timeout
	check(GameManager.phase == "work" and GameManager.days == 1 and GameManager.remaining > 9.7, "Next workday did not begin automatically")
	GameManager.set_process(false)
	resume_ambient_pause = false

func check_savings_hud() -> void:
	GameManager.new_game()
	GameManager.start_shift()
	await get_tree().process_frame
	var screen: FlightScreen = SceneManager.screen_host.get_child(0)
	var previous := GameManager.snapshot()
	check(screen.money_label.text == "$0" and screen.goal_label.text == "$2,100", "HUD initial values incorrect")
	GameManager.tap()
	check(screen.money_label.text == "$5" and screen.savings_tween != null, "Savings feedback did not follow real earnings")
	GameManager.apply_upgrade(item("flights"))
	screen.refresh()
	check(screen.goal_label.text == screen.currency(GameManager.goal()), "HUD ignored goal discount")
	await capture_view("savings", 390)
	GameManager.money = GameManager.goal() - 1
	screen.refresh()
	var remaining := GameManager.remaining
	GameManager.tap()
	check(screen.progress_target == 100 and screen.hud_goal_reached, "HUD did not celebrate goal crossing")
	check(GameManager.phase == "work" and GameManager.remaining == remaining, "HUD interrupted active workday")
	await capture_view("savings_goal", 390)
	var before := GameManager.snapshot()
	screen.refresh()
	check(GameManager.snapshot() == before, "HUD rendering mutated campaign")
	await get_tree().create_timer(0.25).timeout
	check(screen.progress.value == 100, "Animated fill exceeded or missed its cap")
	for width: int in [320, 390]:
		get_tree().root.size = Vector2i(width, 844)
		GameManager.money = 1234567890123
		screen.refresh()
		await capture_view("savings_large", width)
		check(screen.money_label.get_global_rect().end.x <= screen.goal_label.global_position.x, "Large currency overlaps goal")
		check(screen.goal_label.get_global_rect().end.x <= screen.size.x - 20, "Goal exceeds mobile width")
	var reduced := FlightStyle.reduced_motion
	FlightStyle.reduced_motion = true
	GameManager.money = 100
	screen.refresh()
	check(is_equal_approx(screen.progress.value, screen.progress_target), "Reduced-motion bar is still tweening")
	FlightStyle.reduced_motion = reduced
	GameManager.restore(previous)
	get_tree().root.size = Vector2i(390, 844)

func capture_modal_if_suitcase(screen: FlightScreen) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/omf_suitcase_scrolled.png")
	check(screen.item_lists.visible, "Scrolling hid the suitcase")
