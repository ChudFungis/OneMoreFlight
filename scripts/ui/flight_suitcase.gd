class_name FlightSuitcase
extends VBoxContainer
## Local visual collection: fixed touch rectangles, playfully tilted art.
signal item_inspected(item: FlightDefinition, relic: bool)
var item_buttons: Dictionary = {}
var fresh_items: Dictionary = {}
var contents: VBoxContainer
var scroll: ScrollContainer

func _ready() -> void:
	add_theme_constant_override("separation", 4)
	var lid_space := Control.new()
	lid_space.custom_minimum_size.y = 28
	lid_space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lid_space)
	var margins := MarginContainer.new()
	for side: String in ["left", "right"]:
		margins.add_theme_constant_override("margin_" + side, 12)
	margins.add_theme_constant_override("margin_bottom", 12)
	add_child(margins)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margins.add_child(scroll)
	contents = VBoxContainer.new()
	contents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contents.add_theme_constant_override("separation", 5)
	scroll.add_child(contents)
	contents.minimum_size_changed.connect(fit_contents)
	resized.connect(queue_redraw)

func populate(upgrades: Dictionary, relics: Array) -> void:
	# Replacing contents must remove stale buttons and empty-state decorations.
	for child: Node in contents.get_children():
		contents.remove_child(child)
		child.queue_free()
	item_buttons.clear()
	for folder: String in ["upgrades", "relics"]:
		var flow := HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 6)
		flow.add_theme_constant_override("v_separation", 6)
		contents.add_child(flow)
		var ids: Array = upgrades.keys() if folder == "upgrades" else relics
		var catalog: Array = FlightCatalog.UPGRADES if folder == "upgrades" else FlightCatalog.RELICS
		for id: String in ids:
			var key := folder + "/" + id
			if item_buttons.has(key):
				continue
			var item := FlightCatalog.find_item(catalog, id)
			if item != null:
				add_item(flow, item, folder)
		flow.visible = flow.get_child_count() > 0
		if folder == "upgrades" and not upgrades.is_empty() and not relics.is_empty():
			var seam := HSeparator.new()
			seam.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var stitch := StyleBoxLine.new()
			stitch.color = FlightStyle.DEPTH
			stitch.thickness = 1
			seam.add_theme_stylebox_override("separator", stitch)
			contents.add_child(seam)
	if item_buttons.is_empty():
		var empty := FlightArt.image("ui", "airplane")
		empty.custom_minimum_size.y = 52
		empty.modulate.a = 0.3
		contents.add_child(empty)
	fit_contents()

func add_item(flow: HFlowContainer, item: FlightDefinition, folder: String) -> void:
	var key := folder + "/" + item.id
	var control := Button.new()
	control.custom_minimum_size = Vector2(56, 56)
	control.tooltip_text = item.title
	control.accessibility_name = item.title
	for state: String in ["normal", "hover", "pressed"]:
		var surface := StyleBoxFlat.new()
		surface.bg_color = Color.TRANSPARENT if state == "normal" else FlightStyle.PAPER
		surface.set_corner_radius_all(4)
		control.add_theme_stylebox_override(state, surface)
	flow.add_child(control)
	item_buttons[key] = control
	var image := FlightArt.image(folder, item.id, item.icon)
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.offset_left = 7
	image.offset_top = 7
	image.offset_right = -7
	image.offset_bottom = -7
	image.pivot_offset = Vector2(21, 21)
	# Stable per-ID variation consumes no gameplay RNG and never moves hit areas.
	var variation := absi(key.hash())
	image.rotation_degrees = float(variation % 11 - 5)
	image.position.y += float(variation % 3)
	control.add_child(image)
	control.pressed.connect(func() -> void: item_inspected.emit(item, folder == "relics"))
	if fresh_items.has(key) and not FlightStyle.reduced_motion:
		image.scale = Vector2(0.65, 0.65)
		image.modulate.a = 0
		var tween := image.create_tween().set_parallel()
		tween.tween_property(image, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(image, "modulate:a", 1.0, 0.12)

func fit_contents() -> void:
	scroll.custom_minimum_size.y = clampf(contents.get_combined_minimum_size().y, 56, 128)
	queue_redraw()

func _draw() -> void:
	# Hard pixel-like geometry: handle, open lid, lining, hinges and luggage tag.
	draw_rect(Rect2(size.x * 0.5 - 24, 0, 48, 8), FlightStyle.BURGUNDY)
	draw_style_box(FlightStyle.card(true), Rect2(0, 6, size.x, maxf(0, size.y - 6)))
	draw_rect(Rect2(3, 9, maxf(0, size.x - 6), 18), FlightStyle.BLUSH.darkened(0.025))
	draw_line(Vector2(8, 29), Vector2(size.x - 8, 29), FlightStyle.DEPTH, 2)
	for x: float in [18.0, size.x - 28]:
		draw_rect(Rect2(x, 25, 10, 7), FlightStyle.BURGUNDY)
	draw_rect(Rect2(size.x - 28, 9, 12, 13), FlightStyle.PAPER)
	draw_rect(Rect2(size.x - 24, 12, 4, 3), FlightStyle.ROSE)
