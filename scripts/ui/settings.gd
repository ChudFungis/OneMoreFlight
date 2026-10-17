extends FlightScreen
## Compatibility wrapper; shared mobile presentation lives in FlightScreen.
func _ready() -> void:
	view = "settings"
	super._ready()
