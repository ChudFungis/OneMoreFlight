class_name FlightScreen
extends Control
## Shared mobile layout helpers. Rules remain in GameManager.
const STORY = preload("res://resources/story.tres")
const WORKDAY_TRANSITION_SECONDS := 0.4
@export var view: String = "main_menu"
var body: VBoxContainer
var goal_label: Label
var progress_tween: Tween
var savings_tween: Tween
var progress_target: float = -1.0
var displayed_savings: float = -1.0
var hud_initialized: bool = false
var hud_goal_reached: bool = false
var money_label: Label
var timer_label: Label
var item_lists: VBoxContainer
var item_rows: Dictionary = {}
var progress: ProgressBar
var tap_button: Button
var toast: Label
var tap_tween: Tween
var heart_image: TextureRect
var effects_label: Label
var selected_id: String = ""
var selection_cards: Dictionary = {}
var confirm_button: Button
var decision_locked: bool = false
var choice_grid: GridContainer
var ui_rng := RandomNumberGenerator.new()
var feedback_count: int = 0
var last_phase: String = ""
var viewport_width: float = 0
var home_starting: bool = false
var rebuild_generation: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE if view == "game" else Node.PROCESS_MODE_ALWAYS
	GameManager.phase_changed.connect(rebuild)
	GameManager.changed.connect(refresh)
	GameManager.earned.connect(show_earning)
	GameManager.notice.connect(show_notice)
	ui_rng.randomize()
	resized.connect(adapt_layout)
	rebuild()

func label_text(text: String, font_size: int = 18, color: Color = FlightStyle.INK) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_font_override("font", FlightStyle.FONT_HEADING if font_size >= 23 else (FlightStyle.FONT_SEMIBOLD if font_size <= 16 else FlightStyle.FONT_MEDIUM))
	label.add_theme_color_override("font_color", color)
	body.add_child(label)
	return label

func button(text: String, action: Callable, primary: bool = false) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size.y = 56
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_font_size_override("font_size", 19)
	FlightStyle.style_button(result, primary)
	result.pressed.connect(action)
	body.add_child(result)
	return result

func rebuild() -> void:
	if not is_inside_tree():
		return
	# The transition already rendered and faded in this exact workday screen.
	if view == "game" and last_phase in ["transition", "ready"] and GameManager.phase == "work" and is_instance_valid(tap_button):
		tap_button.disabled = false
		last_phase = "work"
		refresh()
		return
	rebuild_generation += 1
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	feedback_count = 0
	selected_id = ""
	selection_cards.clear()
	confirm_button = null
	decision_locked = false
	choice_grid = null
	heart_image = null
	effects_label = null
	if progress_tween != null:
		progress_tween.kill()
	if savings_tween != null:
		savings_tween.kill()
	goal_label = null
	progress_target = -1.0
	displayed_savings = -1.0
	hud_initialized = false
	hud_goal_reached = false
	money_label = null
	timer_label = null
	item_lists = null
	item_rows.clear()
	progress = null
	tap_button = null
	var background := ColorRect.new()
	background.color = FlightStyle.CREAM
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20 if side in ["left", "right"] else 28)
	scroll.add_child(margin)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", FlightStyle.GAP)
	margin.add_child(body)
	match view:
		"main_menu": build_menu()
		"results": build_results()
		"pause_menu": build_pause()
		"settings": build_settings()
		"game": build_game()
		_: build_menu()
	toast = label_text("", 15, FlightStyle.BURGUNDY)
	refresh()
	adapt_layout()
	if not FlightStyle.reduced_motion and not get_tree().paused:
		body.modulate.a = 0
		create_tween().tween_property(body, "modulate:a", 1.0, FlightStyle.ENTER_SECONDS)
	if view == "game":
		if GameManager.phase == "upgrades" and last_phase == "work":
			celebrate("Workday complete")
		elif GameManager.phase == "story" and last_phase in ["ready", "work", "upgrades", "event"]:
			celebrate("One flight closer ✦")
		if GameManager.phase == "ending" and last_phase != "ending":
			celebrate("You made it!", true)
		last_phase = GameManager.phase
		if GameManager.phase in ["transition", "ready"]:
			arm_workday(rebuild_generation)

func arm_workday(generation: int) -> void:
	# One rendered, input-blocked tapping screen; no countdown or overview.
	await get_tree().process_frame
	if not is_inside_tree() or generation != rebuild_generation:
		return
	await get_tree().create_timer(WORKDAY_TRANSITION_SECONDS, false).timeout
	while is_inside_tree() and generation == rebuild_generation and GameManager.phase in ["ready", "transition"]:
		if can_arm_workday(generation):
			# Wait one final input frame after release before enabling the heart.
			await get_tree().process_frame
			if can_arm_workday(generation):
				GameManager.start_shift()
				return
		await get_tree().process_frame

func can_arm_workday(generation: int) -> bool:
	if not is_inside_tree() or generation != rebuild_generation:
		return false
	if GameManager.phase not in ["ready", "transition"] or GameManager.state != GameManager.State.PLAYING:
		return false
	if not GameManager.is_processing() or SceneManager.overlay_host.get_child_count() > 0:
		return false
	if body.modulate.a < 1 or not is_instance_valid(tap_button) or tap_button.size.y <= 0:
		return false
	return not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not Input.is_action_pressed("ui_accept")

func artwork(id: String, height: float = 190, folder: String = "story", explicit: Texture2D = null) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = height
	panel.clip_contents = true
	body.add_child(panel)
	var image := FlightArt.image(folder, id, explicit)
	panel.add_child(image)
	if not FlightStyle.reduced_motion:
		image.modulate.a = 0
		image.create_tween().tween_property(image, "modulate:a", 1.0, FlightStyle.ENTER_SECONDS)

func centered_label(text: String, font_size: int, color: Color = FlightStyle.INK) -> Label:
	var label := label_text(text, font_size, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func pixel_divider() -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	body.add_child(row)
	for id: String in ["sparkle", "heart", "sparkle"]:
		var icon := FlightArt.image("ui", id)
		icon.custom_minimum_size = Vector2(14, 14)
		row.add_child(icon)

func build_menu() -> void:
	pixel_divider()
	centered_label("A LITTLE ADVENTURE FOR YOU", 12, FlightStyle.MUTED)
	centered_label("One More Flight", 36, FlightStyle.BURGUNDY)
	var space := Control.new()
	space.custom_minimum_size.y = 12
	body.add_child(space)
	build_heart(start_adventure)
	tap_button.name = "HomeHeart"
	tap_button.tooltip_text = "Start a fresh adventure"
	tap_button.custom_minimum_size.y = 275
	centered_label("Tap to begin", 18, FlightStyle.BURGUNDY)
	var panel := PanelContainer.new()
	body.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	panel.add_child(content)
	var previous := body
	body = content
	centered_label("Your Best Adventure", 18, FlightStyle.BURGUNDY)
	var best: Dictionary = SaveManager.results.best
	if best.is_empty():
		centered_label("Complete a story to set your first record.", 15, FlightStyle.MUTED)
	else:
		centered_label("%d workdays" % int(best.total_days), 26)
	body = previous
	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 16)
	body.add_child(footer)
	for entry: Array in [["Results", "trophy", show_results], ["Settings", "gear", SceneManager.open_settings]]:
		var control := button(entry[0], entry[2])
		control.icon = FlightArt.texture("ui", entry[1])
		control.expand_icon = true
		control.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		control.custom_minimum_size.x = 110
		control.add_theme_constant_override("icon_max_width", 22)
		control.add_theme_font_size_override("font_size", 15)
		FlightStyle.utility(control, entry[1])
		control.reparent(footer)
	if SaveManager.results.last_error != OK:
		centered_label("Local results couldn’t be saved. Please keep this window open and try again.", 14, FlightStyle.BURGUNDY)

func start_adventure() -> void:
	if home_starting or view != "main_menu":
		return
	home_starting = true
	GameManager.new_game()

func show_results() -> void:
	view = "results"
	rebuild()

func show_home() -> void:
	view = "main_menu"
	rebuild()

func build_results() -> void:
	centered_label("Your Adventures", 29, FlightStyle.BURGUNDY)
	var results: FlightResults = SaveManager.results
	if results.best.is_empty():
		centered_label("No adventures completed yet. Your first one is waiting!", 18)
	else:
		centered_label("YOUR PERSONAL BEST", 13, FlightStyle.MUTED)
		centered_label("%d workdays" % int(results.best.total_days), 30, FlightStyle.BURGUNDY)
		centered_label("Your five most recent adventures", 15, FlightStyle.MUTED)
		for record: Dictionary in results.recent:
			var panel := PanelContainer.new()
			body.add_child(panel)
			var content := VBoxContainer.new()
			content.add_theme_constant_override("separation", 4)
			panel.add_child(content)
			var previous := body
			body = content
			var tied_best := int(record.total_days) == int(results.best.total_days)
			label_text("%s%d workdays" % ["BEST · " if tied_best else "", int(record.total_days)], 21, FlightStyle.BURGUNDY)
			var date := str(record.completed_at).get_slice("T", 0)
			label_text("Adventure #%d%s" % [int(record.attempt), " · " + date + " UTC" if not date.is_empty() else ""], 14, FlightStyle.MUTED)
			if record.chapter_days.size() == 3:
				label_text("Denver %d · Italy %d · Our Future %d" % record.chapter_days, 14, FlightStyle.MUTED)
			body = previous
	button("Back", show_home)

func build_pause() -> void:
	centered_label("A Little Breather", 29, FlightStyle.BURGUNDY)
	centered_label("Josh can wait a minute. Probably.", 18)
	pixel_divider()
	button("Resume", SceneManager.resume_run, true)
	var settings := button("Settings", SceneManager.open_settings)
	FlightStyle.utility(settings, "gear")
	settings.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	settings.custom_minimum_size.x = 230
	var menu := button("Save & Main Menu", GameManager.main_menu)
	FlightStyle.utility(menu, "home")
	menu.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu.custom_minimum_size.x = 230

func build_settings() -> void:
	label_text("Make yourself comfortable", 28)
	for entry: Array in [["Music", "music_volume"], ["SFX", "sfx_volume"]]:
		label_text(entry[0] + " volume")
		var slider := HSlider.new()
		slider.custom_minimum_size.y = 52
		slider.max_value = 100
		slider.step = 1
		slider.value = float(SaveManager.settings[entry[1]]) * 100
		var key: String = entry[1]
		var bus: String = entry[0]
		slider.value_changed.connect(func(value: float) -> void:
			SaveManager.settings[key] = value / 100
			AudioManager.set_volume(bus, value / 100))
		body.add_child(slider)
	label_text("Audio buses are ready for your future soundtrack. This version is silent.", 14)
	if not OS.has_feature("web"):
		var fullscreen := CheckButton.new()
		fullscreen.text = "Fullscreen"
		fullscreen.custom_minimum_size.y = 56
		fullscreen.button_pressed = SaveManager.settings["fullscreen"]
		fullscreen.toggled.connect(func(enabled: bool) -> void:
			SaveManager.settings["fullscreen"] = enabled
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED))
		body.add_child(fullscreen)
	var motion := CheckButton.new()
	motion.text = "Reduced motion"
	motion.custom_minimum_size.y = 56
	motion.button_pressed = FlightStyle.reduced_motion
	motion.toggled.connect(func(enabled: bool) -> void:
		FlightStyle.reduced_motion = enabled
		if FlightStyle.save_preferences() != OK:
			show_notice("Couldn’t save your motion preference. Please try again."))
	body.add_child(motion)
	button("Save & Back", close, true)

func close() -> void:
	if SaveManager.save_data() == OK:
		SceneManager.close_settings()
	else:
		show_notice("Couldn’t save. Please try again before closing.")

func build_game() -> void:
	var shown_day := GameManager.days if GameManager.phase in ["upgrades", "event"] else GameManager.days + 1
	label_text("ONE MORE FLIGHT   /   CHAPTER %d · DAY %d" % [GameManager.chapter + 1, shown_day], 13, FlightStyle.MUTED)
	if GameManager.phase in ["work", "ready", "transition"]:
		build_flight_route()
		build_savings_hud()
	match GameManager.phase:
		"ready", "transition", "work":
			timer_label = label_text("", 30, FlightStyle.BURGUNDY)
			timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			build_heart()
			tap_button.disabled = GameManager.phase != "work"
			var hint := label_text("Tap a little love into the travel fund", 15, FlightStyle.MUTED)
			hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			effects_label = label_text("", 15, FlightStyle.BURGUNDY)
			effects_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		"upgrades":
			label_text("A little more powerful", 27, FlightStyle.BURGUNDY)
			label_text("Workday %d done. Pick one free ability." % GameManager.days, 15, FlightStyle.MUTED)
			build_choices(false)
		"event": build_event()
		"story": build_story()
		"relic":
			pixel_divider()
			label_text("A Memory to Keep", 28, FlightStyle.BURGUNDY)
			label_text("Choose one keepsake. Its bonus stays for every chapter ahead.", 16)
			build_choices(true)
		"ending":
			label_text("You made it!", 28, FlightStyle.BURGUNDY)
			label_text("Your adventure took %d workdays." % GameManager.total_days, 21)
			if GameManager.run_new_best:
				label_text("NEW PERSONAL BEST!", 18, FlightStyle.BURGUNDY)
			artwork("final", 270)
			label_text("No more counting the days apart.", 28, FlightStyle.BURGUNDY)
			label_text(STORY.ending)
			if SaveManager.results.last_error != OK:
				label_text("Couldn’t save your results. Please try again before leaving.", 15)
				button("Retry saving results", func() -> void:
					SaveManager.results.save_data()
					rebuild())
			button("Home", GameManager.main_menu)
			button("Start another adventure", restart_adventure, true)
	if GameManager.phase in ["ready", "transition", "work"]:
		build_item_lists()
	if GameManager.phase not in ["story", "ending"]:
		var pause_control := button("Pause / Save", SceneManager.pause_run)
		pause_control.custom_minimum_size = Vector2(140, 52)
		pause_control.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		pause_control.add_theme_font_size_override("font_size", 15)
		FlightStyle.utility(pause_control, "pause")

func restart_adventure() -> void:
	if decision_locked or GameManager.phase != "ending":
		return
	decision_locked = true
	GameManager.new_game()

func build_item_lists() -> void:
	item_lists = VBoxContainer.new()
	item_lists.add_theme_constant_override("separation", 6)
	body.add_child(item_lists)
	var previous := body
	body = item_lists
	for folder: String in ["upgrades", "relics"]:
		label_text("Abilities" if folder == "upgrades" else "Keepsakes", 16, FlightStyle.BURGUNDY)
		var flow := HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 8)
		flow.add_theme_constant_override("v_separation", 4)
		body.add_child(flow)
		var ids: Array = GameManager.upgrades.keys() if folder == "upgrades" else GameManager.relics
		var catalog: Array = FlightCatalog.UPGRADES if folder == "upgrades" else FlightCatalog.RELICS
		for id: String in ids:
			item_row(flow, FlightCatalog.find_item(catalog, id), folder)
		if ids.is_empty():
			label_text("None yet", 14, FlightStyle.MUTED)
	body = previous

func item_row(flow: HFlowContainer, item: FlightDefinition, folder: String) -> void:
	var row := Button.new()
	row.tooltip_text = item.title
	row.custom_minimum_size = Vector2(150, 52)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = FlightStyle.BLUSH
	pressed.set_corner_radius_all(8)
	row.add_theme_stylebox_override("pressed", pressed)
	row.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	flow.add_child(row)
	item_rows[folder + "/" + item.id] = row
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 6)
	row.add_child(margin)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 8)
	margin.add_child(line)
	var icon := FlightArt.image(folder, item.id, item.icon)
	icon.custom_minimum_size = Vector2(24, 24)
	line.add_child(icon)
	var title := Label.new()
	title.text = item.title
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", FlightStyle.BURGUNDY)
	line.add_child(title)
	line.minimum_size_changed.connect(func() -> void:
		row.custom_minimum_size.y = maxf(52, line.get_combined_minimum_size().y + 12))
	ignore_pointer(margin)
	row.pressed.connect(func() -> void: show_item_details(item, folder == "relics"))

func show_item_details(item: FlightDefinition, relic: bool) -> void:
	if SceneManager.overlay_host.get_child_count() > 0:
		return
	var popup := FlightItemDetails.new()
	popup.item = item
	popup.level = GameManager.count(item.id) if not relic else 0
	popup.is_relic = relic
	SceneManager.overlay_host.add_child(popup)

func build_heart(action: Callable = Callable()) -> void:
	tap_button = Button.new()
	tap_button.name = "TapHeart"
	tap_button.tooltip_text = "Tap to earn travel savings"
	tap_button.custom_minimum_size.y = 250
	tap_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		tap_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	body.add_child(tap_button)
	heart_image = FlightArt.image("heart", "tap")
	heart_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tap_button.add_child(heart_image)
	heart_image.resized.connect(func() -> void: heart_image.pivot_offset = heart_image.size / 2)
	# One input route only. Animation never changes the hit area or awards income.
	if action.is_valid():
		tap_button.pressed.connect(action)
	else:
		tap_button.pressed.connect(func() -> void: GameManager.tap())
	tap_button.button_down.connect(animate_tap)
	tap_button.button_up.connect(release_heart)

func build_choices(relic: bool) -> void:
	choice_grid = GridContainer.new()
	choice_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choice_grid.add_theme_constant_override("h_separation", FlightStyle.GAP)
	choice_grid.add_theme_constant_override("v_separation", FlightStyle.GAP)
	body.add_child(choice_grid)
	var catalog: Array = FlightCatalog.RELICS if relic else FlightCatalog.UPGRADES
	for id: String in GameManager.offers:
		var item := FlightCatalog.find_item(catalog, id)
		choice_card(item, relic)
	confirm_button = button("Select a keepsake" if relic else "Select an ability", commit_choice, true)
	confirm_button.disabled = true

func choice_card(item: FlightDefinition, relic: bool) -> void:
	var card := Button.new()
	card.name = item.id
	card.custom_minimum_size.y = 150 if relic else 128
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("normal", FlightStyle.card(relic))
	card.add_theme_stylebox_override("pressed", FlightStyle.card(relic, true))
	choice_grid.add_child(card)
	selection_cards[item.id] = card
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	card.add_child(margin)
	var row := BoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	var image := FlightArt.image("relics" if relic else "upgrades", item.id, item.icon)
	image.custom_minimum_size = Vector2(100, 100) if relic else Vector2(82, 82)
	row.add_child(image)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 4)
	row.add_child(text)
	var old_body := body
	body = text
	var badge := "PERMANENT KEEPSAKE" if relic else ("NEW" if GameManager.count(item.id) == 0 else "LEVEL %d" % (GameManager.count(item.id) + 1))
	var badge_label := label_text("✦ " + badge, 13, FlightStyle.BURGUNDY)
	badge_label.add_theme_stylebox_override("normal", FlightStyle.badge())
	var title := label_text(item.title, 19, FlightStyle.INK)
	title.add_theme_font_override("font", FlightStyle.FONT_BOLD)
	label_text(effect_summary(item, relic), 15, FlightStyle.MUTED)
	body = old_body
	# Button children need an explicit height derived from their full layout.
	row.minimum_size_changed.connect(func() -> void: fit_card(card, row))
	ignore_pointer(margin)
	card.pressed.connect(func() -> void: select_choice(item.id))

func fit_card(card: Button, row: BoxContainer) -> void:
	card.custom_minimum_size.y = maxf(310 if row.vertical else 128, row.get_combined_minimum_size().y + 24)

func effect_summary(item: FlightDefinition, relic: bool) -> String:
	if relic:
		# The prose precedes the numerical line. Show the original exact effect.
		return item.description.get_slice("\n", 1)
	var level := GameManager.count(item.id) + 1
	match item.id:
		"appointment": return "+%d%% regular tap income" % roundi(level * item.amount * 100)
		"blessing": return "+%d%% event gifts & charges" % roundi(level * item.amount * 100)
		"cabrito": return "Refill %d double taps · %d charge cap" % [int(item.amount), GameManager.balance.burst_cap]
		"cafecito", "team": return "+%ds each workday · shared +%ds cap" % [int(level * item.amount), int(GameManager.balance.max_shift_extension)]
		"empire": return "+%d base taps per second" % int(level * item.amount)
		"facetime": return "+%d base taps every 10th tap" % int(level * item.amount)
		"flights": return "Current travel goal × %.2f" % (1.0 - item.amount)
		"jar": return "+%d%% savings interest each day" % roundi(level * item.amount * 100)
		"love": return "+%d%% per combo step · +90%% cap" % roundi(level * item.amount * 100)
		"playlist": return "+%.1fs every 5th tap · +2s daily cap" % (level * item.amount)
		"tips": return "+%d base taps every 7th tap" % int(level * item.amount)
	return item.description

func ignore_pointer(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Node in node.get_children():
		ignore_pointer(child)

func select_choice(id: String) -> void:
	if decision_locked or not selection_cards.has(id):
		return
	selected_id = id
	var relic := GameManager.phase == "relic"
	for key: String in selection_cards:
		var card: Button = selection_cards[key]
		card.add_theme_stylebox_override("normal", FlightStyle.card(relic, key == id))
		if not FlightStyle.reduced_motion:
			card.modulate = Color.WHITE if key == id else Color(1, 1, 1, 0.65)
	confirm_button.disabled = false
	confirm_button.text = "Keep this memory" if relic else "Take this ability"
	if not FlightStyle.reduced_motion:
		var card: Button = selection_cards[id]
		var tween := card.create_tween()
		tween.tween_property(card, "self_modulate", Color("ffe1ed"), 0.08)
		tween.tween_property(card, "self_modulate", Color.WHITE, FlightStyle.SELECT_SECONDS)

func commit_choice() -> void:
	if decision_locked or selected_id.is_empty():
		return
	decision_locked = true
	var relic := GameManager.phase == "relic"
	var id := selected_id
	# Commit and persist synchronously. No earnings or decisions in Tween callbacks.
	if relic:
		GameManager.choose_relic(id)
	else:
		GameManager.buy_upgrade(id)
	celebrate("A memory for every flight" if relic else "Ability tucked away", relic)

func adapt_layout() -> void:
	if not is_instance_valid(body):
		return
	viewport_width = size.x
	if view in ["main_menu", "results"]:
		var margin: MarginContainer = body.get_parent()
		for side: String in ["left", "right"]:
			margin.add_theme_constant_override("margin_" + side, maxi(20, int((size.x - 520) / 2)))
	if is_instance_valid(choice_grid):
		var wide := size.x >= 720
		choice_grid.columns = 3 if wide else 1
		for card: Button in choice_grid.get_children():
			var row: BoxContainer = card.get_child(0).get_child(0)
			# A wide card keeps the illustration above the text using BoxContainer orientation.
			row.vertical = wide
			var image: TextureRect = row.get_child(0)
			image.custom_minimum_size = Vector2(120, 120) if wide else (Vector2(100, 100) if GameManager.phase == "relic" else Vector2(82, 82))
			fit_card(card, row)

func event_reward(event: FlightDefinition, alternative: bool) -> String:
	var effect := event.alternative_effect if alternative else event.effect
	var amount := event.alternative_amount if alternative else event.amount
	amount *= 1.0 + GameManager.power("blessing")
	if effect == "burst":
		var charges := mini(int(ceilf(amount)), GameManager.balance.burst_cap - GameManager.burst_clicks)
		return "+%d double-tap charges · %d total cap" % [charges, GameManager.balance.burst_cap]
	return "+$%.2f savings" % (amount * GameManager.base_income() * GameManager.global_multiplier())

func build_event() -> void:
	var event := FlightCatalog.find_item(FlightCatalog.EVENTS, GameManager.event_id)
	label_text("A LITTLE PLOT TWIST", 13, FlightStyle.BURGUNDY)
	label_text(event.title, 27)
	artwork(event.id, 175, "events", event.icon)
	label_text(event.description.get_slice("\n", 0), 18)
	button((event.choice if not event.alternative.is_empty() else "Continue") + "\n" + event_reward(event, false), func() -> void: commit_event(false), true)
	if not event.alternative.is_empty():
		button(event.alternative + "\n" + event_reward(event, true), func() -> void: commit_event(true))

func commit_event(alternative: bool) -> void:
	if decision_locked or GameManager.phase != "event":
		return
	decision_locked = true
	GameManager.resolve_event(alternative)
	celebrate("A lovely little bonus")

func build_story() -> void:
	pixel_divider()
	artwork(STORY.illustrations[GameManager.chapter], 280)
	label_text(STORY.titles[GameManager.chapter], 27, FlightStyle.BURGUNDY)
	label_text(STORY.paragraphs[GameManager.chapter])
	button("Our next chapter" if GameManager.chapter < 2 else "Come home", GameManager.finish_story, true)

func build_flight_route() -> void:
	var route := HBoxContainer.new()
	route.add_theme_constant_override("separation", 10)
	body.add_child(route)
	var stops: PackedStringArray = str(GameManager.DESTINATIONS[GameManager.chapter]).split(" → ")
	var previous := body
	# Labels use the same heading treatment while keeping both ends readable.
	for index: int in range(2):
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		route.add_child(column)
		body = column
		var stop := label_text(stops[index], 23, FlightStyle.BURGUNDY)
		stop.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if index == 0 else HORIZONTAL_ALIGNMENT_RIGHT
		if index == 0:
			var plane := FlightArt.image("ui", "airplane")
			plane.custom_minimum_size = Vector2(24, 24)
			plane.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			route.add_child(plane)
	body = previous

func build_savings_hud() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	body.add_child(row)
	var previous := body
	for is_goal: bool in [false, true]:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.size_flags_stretch_ratio = 1.0
		column.add_theme_constant_override("separation", 0)
		row.add_child(column)
		body = column
		var caption := label_text("FLIGHT GOAL" if is_goal else "SAVED", 13, FlightStyle.MUTED)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_goal else HORIZONTAL_ALIGNMENT_LEFT
		var value := label_text("", 24, FlightStyle.BURGUNDY)
		value.add_theme_font_override("font", FlightStyle.FONT_BOLD)
		value.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		value.horizontal_alignment = caption.horizontal_alignment
		value.resized.connect(func() -> void: fit_currency(value))
		if is_goal:
			goal_label = value
		else:
			money_label = value
	body = previous
	progress = ProgressBar.new()
	progress.step = 0.0
	progress.custom_minimum_size.y = 12
	progress.show_percentage = false
	progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(progress)

func currency(amount: float) -> String:
	var digits := "%.0f" % amount
	var grouped := ""
	for index: int in range(digits.length()):
		if index > 0 and (digits.length() - index) % 3 == 0:
			grouped += ","
		grouped += digits[index]
	return "$" + grouped

func fit_currency(value: Label) -> void:
	var font_size := 24
	while font_size > 16 and FlightStyle.FONT_BOLD.get_string_size(value.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > value.size.x:
		font_size -= 1
	value.add_theme_font_size_override("font_size", font_size)

func pulse_savings() -> void:
	if not is_instance_valid(money_label):
		return
	if savings_tween != null and savings_tween.is_running():
		return
	money_label.modulate = FlightStyle.ROSE
	savings_tween = money_label.create_tween()
	savings_tween.tween_property(money_label, "modulate", Color.WHITE, 0.18)

func refresh() -> void:
	if is_instance_valid(money_label) and is_instance_valid(goal_label):
		if displayed_savings >= 0 and GameManager.money > displayed_savings:
			pulse_savings()
		displayed_savings = GameManager.money
		money_label.text = currency(GameManager.money)
		goal_label.text = currency(GameManager.goal())
		fit_currency(money_label)
		fit_currency(goal_label)
	if is_instance_valid(progress):
		var target := clampf(GameManager.money / maxf(GameManager.goal(), 0.01) * 100.0, 0, 100)
		if not hud_initialized or FlightStyle.reduced_motion:
			if progress_tween != null:
				progress_tween.kill()
			progress.value = target
		elif not is_equal_approx(target, progress_target):
			if progress_tween != null:
				progress_tween.kill()
			progress_tween = progress.create_tween()
			progress_tween.tween_property(progress, "value", target, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if hud_initialized and not hud_goal_reached and target >= 100:
			# Visual only: work continues; GameManager settles the milestone.
			feedback("✦ ✦ ✦", progress.global_position + Vector2(progress.size.x * 0.5 - 35, 0), true)
			hud_goal_reached = true
		elif not hud_initialized:
			hud_goal_reached = target >= 100
		hud_initialized = true
		progress_target = target
	if is_instance_valid(timer_label):
		timer_label.text = "Day %d" % (GameManager.days + 1) if GameManager.phase in ["transition", "ready"] else "%.1f seconds" % GameManager.remaining
	if is_instance_valid(effects_label):
		effects_label.text = "Combo %d  ·  %d boosted taps" % [GameManager.combo, GameManager.burst_clicks]
	if GameManager.save_error and is_instance_valid(toast):
		toast.text = "Save unavailable. Keep this tab open and try Pause / Save again."

func animate_tap() -> void:
	if not is_instance_valid(heart_image) or FlightStyle.reduced_motion:
		return
	if tap_tween != null:
		tap_tween.kill()
	heart_image.scale = Vector2(0.94, 0.90)

func release_heart() -> void:
	if not is_instance_valid(heart_image) or FlightStyle.reduced_motion:
		return
	if tap_tween != null:
		tap_tween.kill()
	tap_tween = heart_image.create_tween()
	tap_tween.tween_property(heart_image, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func show_earning(amount: float) -> void:
	if view != "game" or not is_instance_valid(tap_button):
		return
	# The signal's real payout is the sole source of displayed earnings.
	var text := "+$%.2f" % amount
	var at := tap_button.global_position + Vector2(tap_button.size.x * 0.5 - 50, 60)
	if not FlightStyle.reduced_motion:
		at += Vector2(ui_rng.randf_range(-35, 35), ui_rng.randf_range(-12, 12))
	feedback(text, at, false)
	if not FlightStyle.reduced_motion and GameManager.shift_clicks % 6 == 0:
		feedback("✦", at + Vector2(90, 35), true)
	if not FlightStyle.reduced_motion and GameManager.combo >= 4 and is_instance_valid(heart_image):
		heart_image.modulate = Color("ffd1e1")
		heart_image.create_tween().tween_property(heart_image, "modulate", Color.WHITE, 0.12)

func feedback(text: String, at: Vector2, particle: bool) -> void:
	# Keep every earnings label; suppress optional particles during heavy input.
	if particle and feedback_count >= 24:
		return
	feedback_count += 1
	var floating := Label.new()
	floating.text = text
	floating.add_theme_font_size_override("font_size", 22 if particle else 24)
	floating.add_theme_color_override("font_color", FlightStyle.BURGUNDY)
	floating.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floating)
	floating.global_position = at
	var tween := floating.create_tween().set_parallel()
	if not FlightStyle.reduced_motion:
		tween.tween_property(floating, "position:y", floating.position.y - 65, 0.55)
	tween.tween_property(floating, "modulate:a", 0.0, 0.55)
	tween.chain().tween_callback(func() -> void:
		feedback_count = maxi(0, feedback_count - 1)
		floating.queue_free())

func celebrate(message: String, special: bool = false) -> void:
	var banner := Label.new()
	banner.name = "Celebration"
	banner.text = message
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 20)
	banner.add_theme_color_override("font_color", FlightStyle.BURGUNDY)
	banner.add_theme_stylebox_override("normal", FlightStyle.card(true))
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(banner)
	banner.position = Vector2(20, 4)
	banner.size = Vector2(maxf(0, size.x - 40), 45)
	var tween := banner.create_tween()
	tween.tween_interval(0.65 if special else 0.4)
	tween.tween_property(banner, "modulate:a", 0, 0.15)
	tween.tween_callback(banner.queue_free)
	if special and not FlightStyle.reduced_motion:
		for index: int in range(5):
			feedback("✦", Vector2(size.x * (index + 1) / 6, 140 + index * 12), true)

func show_notice(message: String) -> void:
	if is_instance_valid(toast):
		toast.text = message
