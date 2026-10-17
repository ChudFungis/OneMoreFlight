extends Node
## Dedicated buses are ready for future AudioStreamPlayers; no audio assets required.
func _ready() -> void:
	for bus_name: String in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	apply_settings()

func apply_settings() -> void:
	set_volume("Music", float(SaveManager.settings["music_volume"]))
	set_volume("SFX", float(SaveManager.settings["sfx_volume"]))

func set_volume(bus_name: String, volume: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(volume, 0.0001)))
	AudioServer.set_bus_mute(index, volume <= 0.0)
