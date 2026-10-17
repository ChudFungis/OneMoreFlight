class_name FlightStyle
extends RefCounted
## Presentation-only tokens and preference, independent of campaign saves.
const CREAM := Color("fff7ef")
const PAPER := Color("fffdfa")
const INK := Color("582c42")
const MUTED := Color("856473")
const ROSE := Color("d94775")
const BLUSH := Color("f8e0e4")
const BURGUNDY := Color("802f50")
const BORDER := Color("ebcbd2")
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
	box.bg_color = Color("fff0f3") if rich else PAPER
	box.border_color = BURGUNDY if selected else BORDER
	box.set_border_width_all(3 if selected else 1)
	box.set_corner_radius_all(20)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	box.shadow_color = Color(0.38, 0.12, 0.22, 0.08)
	box.shadow_size = 4
	box.shadow_offset = Vector2(0, 3)
	return box

static func make_theme() -> Theme:
	var palette := Theme.new()
	palette.default_font_size = 17
	palette.set_color("font_color", "Label", INK)
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		palette.set_color(state, "Button", INK)
	palette.set_color("font_disabled_color", "Button", MUTED)
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var box := card(false, state == "focus")
		box.bg_color = BLUSH
		if state == "pressed":
			box.bg_color = Color("edbdcc")
		if state == "disabled":
			box.bg_color = Color("eee5e4")
		if state == "focus":
			box.bg_color = Color.TRANSPARENT
		palette.set_stylebox(state, "Button", box)
	palette.set_stylebox("panel", "PanelContainer", card())
	for state: String in ["background", "fill"]:
		var bar := StyleBoxFlat.new()
		bar.bg_color = BLUSH if state == "background" else ROSE
		bar.set_corner_radius_all(6)
		palette.set_stylebox(state, "ProgressBar", bar)
	return palette
