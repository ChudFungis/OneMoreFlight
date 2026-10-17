class_name FlightItemDetails
extends Control
## Local presentation modal. It never changes campaign state or saves.
var item: FlightDefinition
var level: int = 0
var is_relic: bool = false
var previous_focus: Control
var was_processing: bool = false
var closing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	was_processing = GameManager.is_processing()
	GameManager.set_process(false)
	previous_focus = get_viewport().gui_get_focus_owner()
	var shade := ColorRect.new()
	shade.color = Color(0.25, 0.10, 0.18, 0.32)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			close())
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = minf(360, get_viewport_rect().size.x - 40)
	center.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(panel.custom_minimum_size.x - 24, 0)
	panel.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	content.minimum_size_changed.connect(func() -> void:
		scroll.custom_minimum_size.y = minf(content.get_combined_minimum_size().y, get_viewport_rect().size.y - 104))
	var image := FlightArt.image("relics" if is_relic else "upgrades", item.id, item.icon)
	image.custom_minimum_size.y = 64
	content.add_child(image)
	add_label(content, item.title, 23, FlightStyle.BURGUNDY)
	add_label(content, "Permanent keepsake" if is_relic else ("Refills collected: %d" % level if item.max_level == 0 else "Level %d / %d" % [level, item.max_level]), 15, FlightStyle.MUTED)
	add_label(content, item.description.get_slice("\n", 0), 17, FlightStyle.INK)
	add_label(content, "Effect", 15, FlightStyle.BURGUNDY)
	add_label(content, item.description.get_slice("\n", 1), 16, FlightStyle.INK)
	if is_relic and item.id == "bracelet":
		add_label(content, "Applies to taps, passive work and event gifts. Interest is unaffected.", 15, FlightStyle.MUTED)
	if not is_relic and item.id == "cabrito":
		add_label(content, "Repeatable refill · %d / %d shared charges remaining" % [GameManager.burst_clicks, GameManager.balance.burst_cap], 15, FlightStyle.MUTED)
	var done := Button.new()
	done.text = "Close"
	FlightStyle.style_button(done)
	done.custom_minimum_size.y = 52
	done.pressed.connect(close)
	content.add_child(done)
	done.grab_focus()

func add_label(parent: VBoxContainer, text: String, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_font_override("font", FlightStyle.FONT_HEADING if font_size >= 23 else FlightStyle.FONT_MEDIUM)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
	elif event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev"):
		get_viewport().set_input_as_handled()

func close() -> void:
	if closing:
		return
	closing = true
	queue_free()

func _exit_tree() -> void:
	GameManager.set_process(was_processing)
	if GameManager.state == GameManager.State.PLAYING and is_instance_valid(previous_focus) and previous_focus.is_inside_tree():
		previous_focus.grab_focus()
