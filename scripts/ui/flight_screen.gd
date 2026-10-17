class_name FlightScreen
extends Control
## Shared mobile layout helpers. Rules remain in GameManager.
const STORY = preload("res://resources/story.tres")
@export var view: String = "main_menu"
var body: VBoxContainer
var money_label: Label
var timer_label: Label
var bonus_label: Label
var progress: ProgressBar
var tap_button: Button
var toast: Label
var tap_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE if view == "game" else Node.PROCESS_MODE_ALWAYS
	GameManager.phase_changed.connect(rebuild)
	GameManager.changed.connect(refresh)
	GameManager.earned.connect(show_earning)
	GameManager.notice.connect(show_notice)
	rebuild()

func label_text(text: String, font_size: int = 18, color: Color = Color("3e3556")) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
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
	if primary:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("df557d")
		style.set_corner_radius_all(18)
		style.content_margin_left = 14
		style.content_margin_right = 14
		result.add_theme_stylebox_override("normal", style)
		result.add_theme_color_override("font_color", Color.WHITE)
	result.pressed.connect(action)
	body.add_child(result)
	return result

func rebuild() -> void:
	if not is_inside_tree():
		return
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	money_label = null
	timer_label = null
	bonus_label = null
	progress = null
	tap_button = null
	var background := ColorRect.new()
	background.color = Color("fff5ed")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20 if side in ["left", "right"] else 24)
	scroll.add_child(margin)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	margin.add_child(body)
	match view:
		"main_menu": build_menu()
		"pause_menu": build_pause()
		"settings": build_settings()
		"game": build_game()
		_: build_menu()
	toast = label_text("", 15, Color("bd436b"))
	refresh()
	body.modulate.a = 0
	create_tween().tween_property(body, "modulate:a", 1.0, 0.18)

func artwork(id: String, height: float = 190) -> void:
	var texture: Texture2D
	for extension: String in ["png", "webp", "svg"]:
		var path := "res://assets/art/story/%s.%s" % [id, extension]
		if ResourceLoader.exists(path):
			texture = load(path) as Texture2D
			break
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = height
	panel.clip_contents = true
	body.add_child(panel)
	if texture != null:
		var image := TextureRect.new()
		image.texture = texture
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		panel.add_child(image)
		image.resized.connect(func() -> void: image.pivot_offset = image.size / 2)
		var tween := image.create_tween().set_loops()
		tween.tween_property(image, "scale", Vector2(1.025, 1.025), 2.5)
		tween.tween_property(image, "scale", Vector2.ONE, 2.5)
	else:
		var fallback := Label.new()
		fallback.text = "♡   ONE MORE FLIGHT   ✈"
		fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(fallback)

func build_menu() -> void:
	label_text("ONE MORE FLIGHT", 33, Color("bd436b"))
	label_text("A little hustle. A lot of love.", 18)
	artwork("main_menu", 220)
	label_text("Dani’s spa is in Monterrey. Josh is a flight away. Tap through workdays, build a tiny spa empire, and turn ‘I miss you’ into ‘I’m here.’")
	if GameManager.has_save():
		button("Continue Game", GameManager.continue_game, true)
	button("New Game", confirm_new_game, not GameManager.has_save())
	button("Settings", SceneManager.open_settings)
	if not OS.has_feature("web"):
		button("Quit", func() -> void: get_tree().quit())
	label_text("Three chapters · play at your own pace · saves on this device", 14)

func confirm_new_game() -> void:
	if not GameManager.has_save():
		GameManager.new_game()
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "Start a new love story?"
	dialog.dialog_text = "This replaces your saved chapters, upgrades, and relics."
	dialog.ok_button_text = "New Game"
	dialog.cancel_button_text = "Keep my progress"
	dialog.confirmed.connect(GameManager.new_game)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(320, 200))

func build_pause() -> void:
	label_text("A little breather ♡", 29)
	label_text("Your workday is paused. Josh can wait a minute. Probably.")
	button("Resume", SceneManager.resume_run, true)
	button("Settings", SceneManager.open_settings)
	button("Save & Main Menu", GameManager.main_menu)

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
	button("Save & Back", close, true)

func close() -> void:
	if SaveManager.save_data() == OK:
		SceneManager.close_settings()
	else:
		show_notice("Couldn’t save. Please try again before closing.")

func build_game() -> void:
	label_text("CHAPTER %d / 3  ·  DAY %d" % [GameManager.chapter + 1, GameManager.days + 1], 14, Color("bd436b"))
	label_text(GameManager.CHAPTERS[GameManager.chapter], 27)
	label_text(GameManager.DESTINATIONS[GameManager.chapter], 16)
	if GameManager.phase not in ["story", "relic", "ending"]:
		money_label = label_text("", 24)
		progress = ProgressBar.new()
		progress.custom_minimum_size.y = 16
		progress.show_percentage = false
		body.add_child(progress)
	match GameManager.phase:
		"ready":
			artwork("main_menu", 150)
			label_text("Ready for work?", 25)
			label_text("Tap to earn during a 15-second spa workday. Then choose upgrades—or keep the money for your ticket.")
			button("Begin workday", GameManager.start_shift, true)
			trip_button()
		"work":
			timer_label = label_text("", 30, Color("bd436b"))
			tap_button = button("♡\nWORK AT THE SPA\nTap to bring Josh closer", func() -> void: GameManager.tap(), true)
			tap_button.custom_minimum_size.y = 220
			tap_button.button_down.connect(animate_tap)
			label_text("Every little tap is one little step closer.", 16)
		"upgrades":
			label_text("Workday %d complete!" % GameManager.days, 25)
			label_text("Pick any you can afford. Saving your money is a strategy too.", 16)
			trip_button()
			for id: String in GameManager.offers:
				var item := FlightCatalog.find_item(FlightCatalog.UPGRADES, id)
				content_card(item, "Buy · $%.0f" % GameManager.price(item), func() -> void: GameManager.buy_upgrade(id), GameManager.money < GameManager.price(item), "upgrades")
			button("Keep savings → Next workday", GameManager.next_day, true)
		"event": build_event()
		"story": build_story()
		"relic":
			label_text("A little love to take with you", 26)
			label_text("Choose one permanent relic. It stays with you when money and regular upgrades reset.")
			for id: String in GameManager.offers:
				var item := FlightCatalog.find_item(FlightCatalog.RELICS, id)
				content_card(item, "Take this keepsake", func() -> void: GameManager.choose_relic(id), false, "relics")
		"ending":
			artwork("final", 270)
			label_text("No more counting the days apart.", 28, Color("bd436b"))
			label_text(STORY.ending)
			label_text("Three trips. %d workdays. One very determined heart." % GameManager.total_days)
			button("Back to Main Menu", GameManager.main_menu, true)
	if GameManager.phase not in ["story", "ending"]:
		bonus_label = label_text("", 14)
		button("Pause / Save", SceneManager.pause_run)

func trip_button() -> void:
	var affordable := GameManager.money >= GameManager.goal()
	var result := button("Buy this trip ♡" if affordable else "Ticket goal · $%.0f" % GameManager.goal(), func() -> void: GameManager.buy_trip(), affordable)
	result.disabled = not affordable

func content_card(item: FlightDefinition, action_text: String, action: Callable, disabled: bool, folder: String) -> void:
	var panel := PanelContainer.new()
	body.add_child(panel)
	var card := VBoxContainer.new()
	card.add_theme_constant_override("separation", 8)
	panel.add_child(card)
	var old_body := body
	body = card
	var icon := item.icon
	if icon == null:
		for extension: String in ["png", "webp", "svg"]:
			var path := "res://assets/art/%s/%s.%s" % [folder, item.id, extension]
			if ResourceLoader.exists(path):
				icon = load(path) as Texture2D
				break
	if icon == null:
		icon = preload("res://assets/art/icon_placeholder.svg")
	var image := TextureRect.new()
	image.texture = icon
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(48, 48)
	body.add_child(image)
	label_text(item.title, 21, Color("bd436b"))
	label_text(item.description, 16)
	var buy := button(action_text, action)
	buy.disabled = disabled
	body = old_body

func build_event() -> void:
	var event := FlightCatalog.find_item(FlightCatalog.EVENTS, GameManager.event_id)
	label_text("A little plot twist…", 26, Color("bd436b"))
	label_text(event.title, 24)
	label_text(event.description)
	button("Accept outcome", func() -> void: GameManager.resolve_event(), true)
	if not event.alternative.is_empty():
		button(event.alternative, func() -> void: GameManager.resolve_event(true))
	if GameManager.shields > 0:
		label_text("Abuela’s Blessing: protected against a negative outcome.", 15)

func build_story() -> void:
	artwork(STORY.illustrations[GameManager.chapter], 280)
	label_text(STORY.titles[GameManager.chapter], 27, Color("bd436b"))
	label_text(STORY.paragraphs[GameManager.chapter])
	button("Our next chapter ♡" if GameManager.chapter < 2 else "Come home ♡", GameManager.finish_story, true)

func refresh() -> void:
	if is_instance_valid(money_label):
		money_label.text = "$%.0f saved / $%.0f ticket" % [GameManager.money, GameManager.goal()]
	if is_instance_valid(progress):
		progress.value = lerpf(progress.value, minf(100, GameManager.money / GameManager.goal() * 100), 0.35)
	if is_instance_valid(timer_label):
		timer_label.text = "%.1fs  ·  %d taps" % [GameManager.remaining, GameManager.shift_clicks]
	if is_instance_valid(bonus_label):
		var names: PackedStringArray = []
		for id: String in GameManager.upgrades:
			var item := FlightCatalog.find_item(FlightCatalog.UPGRADES, id)
			names.append("%s ×%d" % [item.title, GameManager.count(id)])
		for id: String in GameManager.relics:
			names.append("♡ " + FlightCatalog.find_item(FlightCatalog.RELICS, id).title)
		bonus_label.text = "Bonuses: " + (", ".join(names) if not names.is_empty() else "A fresh start and a big dream.")
		if GameManager.phase == "work":
			bonus_label.text += "\nCombo %d · Boosted taps %d · Shields %d" % [GameManager.combo, GameManager.burst_clicks, GameManager.shields]
	if GameManager.save_error and is_instance_valid(toast):
		toast.text = "Save unavailable. Keep this tab open and try Pause / Save again."

func animate_tap() -> void:
	if not is_instance_valid(tap_button):
		return
	if tap_tween != null:
		tap_tween.kill()
	tap_button.pivot_offset = tap_button.size / 2
	tap_button.scale = Vector2(0.96, 0.96)
	tap_tween = create_tween()
	tap_tween.tween_property(tap_button, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)

func show_earning(amount: float) -> void:
	if view != "game" or not is_instance_valid(tap_button):
		return
	var floating := Label.new()
	floating.text = "+$%.0f ♡" % amount
	floating.add_theme_font_size_override("font_size", 28)
	floating.add_theme_color_override("font_color", Color("bd436b"))
	floating.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floating)
	floating.position = tap_button.global_position + Vector2(tap_button.size.x * 0.3, 50)
	var tween := create_tween().set_parallel()
	tween.tween_property(floating, "position:y", floating.position.y - 85, 0.65)
	tween.tween_property(floating, "modulate:a", 0.0, 0.65)
	tween.chain().tween_callback(floating.queue_free)

func show_notice(message: String) -> void:
	if is_instance_valid(toast):
		toast.text = message
