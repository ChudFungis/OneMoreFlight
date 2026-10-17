# One More Flight

A mobile-first, romantic incremental roguelike clicker about Dani’s Monterrey spa, Josh, and three trips that bring them closer. Built with Godot 4 / typed GDScript, no plugins or third-party dependencies. Compatibility rendering supports Intel Macs and the intended Web build.

## Play

Open `project.godot` in **Godot 4.7.2 standard** and press **F5**. The portrait reference size is 390 × 844; smaller screens scroll. All actions use touch/mouse controls.

1. New Game begins the Denver chapter. Continue restores the saved decision or remaining workday time. Starting over requires confirmation.
2. Begin a 15-second workday and tap the big spa button. Money is both upgrade currency and travel savings.
3. After each workday, choose among three random upgrades, buy any you can afford, or keep your savings. Every third workday has a 40% chance of an event.
4. Buy the trip between workdays when you can afford it. Read the reunion scene and choose one of three permanent relics. Money and ordinary upgrades reset for the next chapter; relics stay.
5. Complete Denver, Italy, and the final one-way ticket to reach the ending.

Pause / Save freezes work; Settings and Main Menu remain available. Losing application focus pauses the campaign. The game saves after decisions, when pausing, and every two seconds of active work. No offline earnings or real-money purchases. Audio buses/settings are retained; this version intentionally has no soundtrack.

## Project map

- `scenes/main.tscn`: persistent screen and overlay hosts, reused from the foundation.
- `scenes/`: main menu, game, pause and settings screen entry points.
- `scripts/managers/`: run/economy rules, navigation, audio, local persistence.
- `scripts/data/`: typed content Resources and explicit export-safe catalogue.
- `scripts/ui/`: shared portrait screen presentation and theme.
- `resources/balance.tres`: economy/timer/probability knobs.
- `resources/story.tres`: replaceable chapter prose and illustration IDs.
- `resources/upgrades/`, `relics/`, `events/`: editable content definitions.
- `assets/art/`: replaceable story and icon artwork; [exact paths](docs/ARTWORK.md).
- `tests/`: deterministic checks and complete-campaign economy simulations.

## Run checks

From the project directory:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . tests/test_foundation.tscn
```

Use `godot` instead of the application path if installed on PATH. The suite uses a separate `/tmp/one_more_flight_tests.json`, removes it afterward, and never overwrites a player save. Run one test instance at a time. A corrupt-save recovery warning is intentional. Graphical tests can be run by removing `--headless`.

Local saves use `user://save_data.json`, normally `~/Library/Application Support/Godot/app_userdata/One More Flight/` on macOS. Saves stay on the device/browser. The original prototype’s empty progression envelope is not a campaign save; Continue appears only for a versioned campaign.

Read [architecture](docs/ARCHITECTURE.md), [content and balance](docs/GAME_DESIGN.md), [art replacement](docs/ARTWORK.md), [Web export](docs/WEB_EXPORT.md), and [validation](docs/VALIDATION.md).
