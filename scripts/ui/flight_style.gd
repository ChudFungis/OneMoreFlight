class_name FlightStyle
extends RefCounted
## Presentation-only tokens and preference, independent of campaign saves.
const CREAM := Color("fff6f0")
const PAPER := Color("fffcfa")
const INK := Color("762b4b")
const MUTED := Color("856473")
const ROSE := Color("ed7fa4")
const BLUSH := Color("f8dce6")
const BURGUNDY := Color("762b4b")
const BORDER := Color("9e355d")
const DEPTH := Color("bd6b8b")
const FONT_MEDIUM = preload("res://assets/fonts/baloo_medium.tres")
const FONT_SEMIBOLD = preload("res://assets/fonts/baloo_semibold.tres")
const FONT_BOLD = preload("res://assets/fonts/baloo_bold.tres")
const FONT_HEADING = preload("res://assets/fonts/baloo_extrabold.tres")
const GAP := 10
const ENTER_SECONDS := 0.18
const SELECT_SECONDS := 0.22
static var reduced_motion: bool = false
static var preference_path: String = "user://presentation.cfg"

static func load_preferences() -> void:
	var config := ConfigFile.new()
	if config.load(preference_path) == OK:
		reduced_motion = config.get_value("visuals", "reduced_motion", false) == true

static func save_preferences() -> Error:
	var config := ConfigFile.new()
	config.set_value("visuals", "reduced_motion", reduced_motion)
	return config.save(preference_path)

static func card(rich: bool = false, selected: bool = false) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = BLUSH if rich else PAPER
	box.border_color = ROSE if selected else BURGUNDY
	box.set_border_width_all(4 if selected else 2)
	box.set_corner_radius_all(5)
	box.set_content_margin_all(12)
	box.shadow_color = DEPTH
	box.shadow_size = 1
	box.anti_aliasing = false
	box.shadow_offset = Vector2(0, 5 if rich or selected else 3)
	return box

static func badge() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = BLUSH
	box.set_content_margin_all(4)
	box.set_corner_radius_all(2)
	return box

static func button_style(primary: bool, pressed: bool = false) -> StyleBoxFlat:
	var box := card()
	box.bg_color = ROSE if primary else BLUSH
	box.shadow_offset.y = 1 if pressed else 5
	box.content_margin_top = 15 if pressed else 11
	box.content_margin_bottom = 7 if pressed else 11
	return box

static func style_button(control: Button, primary: bool = false) -> void:
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		var box := button_style(primary, state == "pressed")
		if state == "hover":
			box.bg_color = box.bg_color.lightened(0.08)
		if state == "disabled":
			box.bg_color = BLUSH.darkened(0.05)
			box.shadow_offset.y = 1
		control.add_theme_stylebox_override(state, box)
	control.add_theme_font_override("font", FONT_BOLD if primary else FONT_SEMIBOLD)
	# The style moves label padding and collapses depth immediately; this tween
	# only adds a brief release sheen and never invokes a gameplay callback.
	control.button_up.connect(func() -> void:
		if not reduced_motion:
			control.self_modulate = Color("fff0f6")
			control.create_tween().tween_property(control, "self_modulate", Color.WHITE, 0.12))

static func utility(control: Button, icon_id: String) -> void:
	control.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	control.alignment = HORIZONTAL_ALIGNMENT_LEFT
	control.icon = FlightArt.texture("ui", icon_id)
	control.expand_icon = true
	control.add_theme_constant_override("icon_max_width", 20)
	control.add_theme_font_size_override("font_size", 16)
	for state: String in ["normal", "hover", "pressed"]:
		var box := StyleBoxFlat.new()
		box.bg_color = BLUSH if state != "normal" else Color.TRANSPARENT
		box.set_content_margin_all(6)
		box.set_corner_radius_all(3)
		control.add_theme_stylebox_override(state, box)

static func make_theme() -> Theme:
	var palette := Theme.new()
	palette.default_font = FONT_MEDIUM
	palette.default_font_size = 18
	palette.set_color("font_color", "Label", INK)
	for type: String in ["Button", "CheckButton", "TooltipLabel"]:
		palette.set_font("font", type, FONT_SEMIBOLD)
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		palette.set_color(state, "Button", INK)
	palette.set_color("font_disabled_color", "Button", MUTED)
	for state: String in ["checked", "checked_disabled", "unchecked", "unchecked_disabled"]:
		palette.set_icon(state, "CheckButton", FlightArt.texture("ui", "toggle_on" if state.begins_with("checked") else "toggle_off"))
	for state: String in ["grabber", "grabber_highlight", "grabber_disabled"]:
		palette.set_icon(state, "HSlider", FlightArt.texture("ui", "knob"))
	for state: String in ["slider", "grabber_area", "grabber_area_highlight"]:
		var track := StyleBoxFlat.new()
		track.bg_color = BLUSH if state == "slider" else ROSE
		track.border_color = BURGUNDY
		track.set_border_width_all(1)
		track.content_margin_top = 4
		track.content_margin_bottom = 4
		palette.set_stylebox(state, "HSlider", track)
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var box := button_style(false, state == "pressed")
		if state == "focus":
			box.bg_color = Color.TRANSPARENT
			box.border_color = ROSE
		palette.set_stylebox(state, "Button", box)
	palette.set_stylebox("panel", "PanelContainer", card())
	palette.set_stylebox("panel", "TooltipPanel", card())
	palette.set_color("font_color", "TooltipLabel", INK)
	for state: String in ["background", "fill"]:
		var bar := StyleBoxFlat.new()
		bar.bg_color = BLUSH if state == "background" else ROSE
		bar.border_color = BURGUNDY
		bar.set_border_width_all(1)
		bar.set_corner_radius_all(2)
		palette.set_stylebox(state, "ProgressBar", bar)
	return palette
