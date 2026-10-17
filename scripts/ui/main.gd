extends Control
## Persistent hosts share one presentation theme; campaign ownership is unchanged.
func _ready() -> void:
	FlightStyle.load_preferences()
	theme = FlightStyle.make_theme()
	SceneManager.register_hosts($Screens, $Overlays)
