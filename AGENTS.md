# Development instructions

Read README.md and docs/ARCHITECTURE.md before changing the project. The owner has authorized the three-chapter One More Flight clicker described in docs/GAME_DESIGN.md; do not add unrelated combat, monetization, online systems, or elaborate frameworks.

## Architecture and code

- Keep the four existing autoloads: GameManager (rules/state), SceneManager (screen/overlay lifetime), SaveManager (local JSON), AudioManager (bus settings). Prefer local nodes and native signals over new autoloads/event buses.
- UI forwards input and renders state. Economy must use GameManager; deterministic tests call the same advance_time/tap methods as gameplay.
- Use typed Godot 4 GDScript, tabs, snake_case files/functions/variables, PascalCase class names, and UPPER_SNAKE_CASE constants. Keep code beginner-readable and dependencies absent unless required.
- Use custom Resources for content. Stable IDs are save identifiers: do not rename them without migration. Register new content in FlightCatalog so exports include it. Add explicit rules/tests when adding effect types.
- Edit resource amounts/prices and balance.tres for tuning. Story prose belongs in story.tres. Keep descriptions consistent with effects.
- Preserve the persistent host and pause-aware overlays. Gameplay pauses; menus remain responsive. Settings opened from Pause returns to Pause. Never award earnings from UI animation callbacks.
- Persist important decisions, offers, relic choices and temporary charges. Tests must isolate SaveManager.save_path before any campaign action. Do not overwrite player saves.
- Keep Compatibility rendering and single-thread Web compatibility. No desktop-only gameplay input or hover-only interactions. Use containers, wrapping, scroll views and large touch targets.
- Preserve predictable artwork paths and fallback behavior from docs/ARTWORK.md. Do not generate portraits without owner direction. Do not couple images to hardcoded texture dimensions.
- Do not edit .gitignore or editor setup without a task reason. Avoid speculative abstractions, generic effect interpreters and premature systems.

## Validation and delivery

- Run the README headless editor import and tests/test_foundation.tscn after rule, content or navigation changes. Inspect Godot output even when exit code is zero.
- Add meaningful coverage for changed rules, synergies, saves and chapter transitions. Keep full-campaign reachability simulations.
- For UI changes, render portrait screenshots and inspect them; validate minimum-width scrolling and touch targets. Report physical-device/browser limits clearly.
- Keep docs current, including measured balance results and outstanding manual checks. Do not claim human 10–15 minute pacing from accelerated simulations.
- Review status and whitespace before delivery, preserve user edits, and prepare a clear commit summary. Do not commit, push, publish or deploy unless requested.
