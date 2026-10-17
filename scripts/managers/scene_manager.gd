extends Node
## Owns navigation, not run data. All screen paths live here.
const SCREENS := {
	"main_menu": preload("res://scenes/main_menu.tscn"),
	"game": preload("res://scenes/game.tscn"),
	"pause_menu": preload("res://scenes/pause_menu.tscn"),
	"settings": preload("res://scenes/settings.tscn"),
	"game_over": preload("res://scenes/game_over.tscn")
}
var screen_host: Control
var overlay_host: Control
var settings_from_pause: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not OS.has_feature("web"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if SaveManager.settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED)

func register_hosts(screens: Control, overlays: Control) -> void:
	screen_host = screens
	overlay_host = overlays
	show_screen("main_menu")

func clear_host(host: Control) -> void:
	for child: Node in host.get_children():
		host.remove_child(child)
		child.queue_free()

func show_screen(screen_name: String) -> void:
	get_tree().paused = false
	clear_host(overlay_host)
	clear_host(screen_host)
	screen_host.add_child(SCREENS[screen_name].instantiate())

func show_overlay(screen_name: String) -> void:
	clear_host(overlay_host)
	overlay_host.add_child(SCREENS[screen_name].instantiate())

func pause_run() -> void:
	if GameManager.state != GameManager.State.PLAYING:
		return
	GameManager.set_state(GameManager.State.PAUSED)
	GameManager.persist()
	get_tree().paused = true
	show_overlay("pause_menu")

func resume_run() -> void:
	clear_host(overlay_host)
	get_tree().paused = false
	GameManager.set_state(GameManager.State.PLAYING)

func open_settings() -> void:
	settings_from_pause = GameManager.state == GameManager.State.PAUSED
	show_overlay("settings")

func close_settings() -> void:
	if settings_from_pause:
		show_overlay("pause_menu")
	else:
		clear_host(overlay_host)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if overlay_host.get_child_count() > 0 and overlay_host.get_child(0).name == "Settings":
			overlay_host.get_child(0).close()
		elif GameManager.state == GameManager.State.PAUSED:
			resume_run()
		elif GameManager.state == GameManager.State.PLAYING:
			pause_run()
		get_viewport().set_input_as_handled()
