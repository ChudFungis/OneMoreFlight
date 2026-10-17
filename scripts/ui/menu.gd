extends FlightScreen
## Compatibility wrapper; shared mobile presentation lives in FlightScreen.
func _ready() -> void:
	view = "main_menu"
	super._ready()
