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
	GameManager.set_process(false)
	# Load retained scripts inside the project runtime so autoloads are present.
	for path: String in ["res://scripts/ui/game.gd", "res://scripts/ui/menu.gd", "res://scripts/ui/settings.gd"]:
		var script := load(path) as Script
		check(script != null and script.can_instantiate(), "Retained script does not compile: " + path)
	main = preload("res://scenes/main.tscn").instantiate()
	add_child(main)
	check(SceneManager.screen_host.get_child(0).view == "main_menu", "Main menu missing")
	GameManager.new_game()
	check(GameManager.phase == "ready" and GameManager.money == 0, "New game did not reset")
	GameManager.start_shift()
	check(is_equal_approx(GameManager.remaining, 15), "Shift length incorrect")
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
	check(is_equal_approx(GameManager.tap(), 10.4), "Combo / appointment synergy failed")
	GameManager.since_tap = 2
	check(is_equal_approx(GameManager.tap(), 7.15), "Combo did not reset after delay")
	GameManager.upgrades = {}
	GameManager.money = 0
	GameManager.apply_upgrade(item("empire"))
	GameManager.apply_upgrade(item("team"))
	GameManager.money = 0
	GameManager.advance_time(1)
	check(is_equal_approx(GameManager.money, 22.5), "Passive / besties synergy failed")
	GameManager.apply_upgrade(item("playlist"))
	GameManager.shift_clicks = 4
	before = GameManager.remaining
	GameManager.tap()
	check(is_equal_approx(GameManager.remaining, before + 0.15), "Playlist extension failed")
	GameManager.upgrades = {}
	GameManager.remaining = 0.1
	GameManager.advance_time(0.1)
	check(GameManager.days == 1 and GameManager.phase == "upgrades", "Timer did not end workday exactly once")
	GameManager.advance_time(10)
	check(GameManager.days == 1, "Timer completed twice")
	check(GameManager.offers.size() == 3, "Expected 3 upgrade offers")
	GameManager.money = 0
	check(not GameManager.buy_upgrade(GameManager.offers[0]), "Unaffordable purchase accepted")
	GameManager.money = 1000
	var id: String = GameManager.offers[0]
	check(GameManager.buy_upgrade(id) and GameManager.count(id) > 0, "Purchase failed")
	check(not GameManager.buy_upgrade(id), "Offer purchased twice")
	GameManager.upgrades = {}
	GameManager.burst_clicks = 0
	GameManager.goal_multiplier = 1
	GameManager.phase = "ready"
	GameManager.apply_upgrade(item("cafecito"))
	GameManager.start_shift()
	check(is_equal_approx(GameManager.remaining, 18), "Coffee duration failed")
	GameManager.apply_upgrade(item("flights"))
	check(is_equal_approx(GameManager.goal(), 2100 * 0.88), "Ticket discount failed")
	GameManager.relics = ["passport"]
	check(is_equal_approx(GameManager.goal(), 2100 * 0.88 * 0.88), "Passport discount synergy failed")
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
	check(is_equal_approx(GameManager.money, 108), "Interest failed")
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
			check(GameManager.phase == "upgrades" and GameManager.money >= 0, "Event failed: " + event.id)
	GameManager.phase = "event"
	GameManager.event_id = "cancelled"
	GameManager.money = 1000
	GameManager.shields = 1
	GameManager.resolve_event()
	check(GameManager.money == 1000 and GameManager.shields == 0, "Shield failed")
	var balance: FlightBalance = GameManager.balance
	var old_probability: float = balance.event_probability
	balance.event_probability = 1
	GameManager.phase = "work"
	GameManager.days = 2
	GameManager.finish_shift()
	check(GameManager.phase == "event", "Third-day event roll missing")
	balance.event_probability = 0
	GameManager.phase = "work"
	GameManager.days = 5
	GameManager.finish_shift()
	check(GameManager.phase == "upgrades", "Event probability zero ignored")
	balance.event_probability = old_probability
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
			"ready": GameManager.start_shift()
			"work":
				while GameManager.phase == "work":
					GameManager.tap()
					GameManager.advance_time(1.0 / rate)
					work_seconds += 1.0 / rate
			"event": GameManager.resolve_event(true)
			"upgrades":
				if GameManager.money >= GameManager.goal():
					chapter_days.append(GameManager.days)
					check(GameManager.buy_trip(), "Earned trip could not be purchased")
				else:
					# Purchase at most one useful upgrade/day; keep savings late in chapter.
					if GameManager.days <= 4:
						for preferred: String in ["empire", "facetime", "love", "appointment", "tips", "cafecito", "flights"]:
							if preferred in GameManager.offers and GameManager.buy_upgrade(preferred):
								break
					GameManager.next_day()
			"story": GameManager.finish_story()
			"relic": GameManager.choose_relic(GameManager.offers[0])
		await get_tree().process_frame
	check(GameManager.complete and GameManager.completed_chapters.size() == 3 and GameManager.relics.size() == 2, "Full game not reachable at %d taps/sec" % rate)
	print("Balance simulation %d taps/sec: days %s, working %.1fs" % [rate, chapter_days, work_seconds])
