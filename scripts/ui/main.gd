extends Control
## The original persistent screen/overlay host, with one shared mobile theme.
func _ready() -> void:
	var palette := Theme.new()
	palette.default_font_size = 18
	palette.set_color("font_color", "Button", Color("493958"))
	palette.set_color("font_hover_color", "Button", Color("493958"))
	palette.set_color("font_pressed_color", "Button", Color("493958"))
	palette.set_color("font_disabled_color", "Button", Color("8b7a86"))
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("f7d9cf") if state != "disabled" else Color("e8e1dc")
		if state == "pressed":
			style.bg_color = Color("eabac8")
		if state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.border_color = Color("bd436b")
			style.set_border_width_all(2)
		style.set_corner_radius_all(18)
		style.content_margin_left = 16
		style.content_margin_right = 16
		style.content_margin_top = 10
		style.content_margin_bottom = 10
		palette.set_stylebox(state, "Button", style)
	var card := StyleBoxFlat.new()
	card.bg_color = Color("fffdfa")
	card.set_corner_radius_all(18)
	card.content_margin_left = 16
	card.content_margin_right = 16
	card.content_margin_top = 16
	card.content_margin_bottom = 16
	palette.set_stylebox("panel", "PanelContainer", card)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("df557d")
	fill.set_corner_radius_all(8)
	palette.set_stylebox("fill", "ProgressBar", fill)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("f1dfd7")
	track.set_corner_radius_all(8)
	palette.set_stylebox("background", "ProgressBar", track)
	theme = palette
	SceneManager.register_hosts($Screens, $Overlays)
