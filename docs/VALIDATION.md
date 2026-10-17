# Validation and delivery

## Automated validation

Validated with Godot 4.7.2 stable on Intel macOS, using the Compatibility renderer. The integration suite runs actual scenes and shared economy code without external dependencies.

The final suite reports **87 checks, zero failures**. Checks cover retained-script compilation inside the autoload-enabled project; base income; timer completion exactly once; pause blocking taps/time; Settings returning to Pause; purchase affordability and duplicate-offer protection; combo timeout; Cabrito charge consumption; FaceTime + relic and passive-income synergies; playlist extension; coffee duration; interest; ticket/Passport discounts; Hoodie/Bracelet stacking; seventh-tap tips; audio-settings persistence and mute; all eight events and their alternative outcomes; negative-event protection; event probability 0/1 on the third day; save/load snapshot equality with float tolerance; regular-upgrade reset; relic preservation and free-upgrade behavior; completed-save Continue; corrupt-save recovery; portrait viewport configuration; and three deterministic full campaigns at 2/3/4 taps/sec.

Graphical runs use Intel Iris Plus OpenGL Compatibility. Gameplay and final-ending screenshots were rendered at 390 × 844 and visually inspected for contrast, wrapping and touch-target layout. Long ending text scrolls. A single warning from deliberately invalid JSON is expected during the recovery test. No personalized art or audio is required.

Tests save only to `/tmp/one_more_flight_tests.json`. They never replace a player save. Automated simulations advance the same timer function as real gameplay without waiting for wall-clock workdays. This validates rules and reachability, not actual human session duration.

## Manual checks still required

- Human click-through of New Game confirmation, all menus, scrolling upgrade/relic choices, pause, and Settings.
- iPhone Safari touch input, fast taps versus page scrolling, safe areas, orientation and browser address-bar resizing.
- Web export and browser-storage reload/close/reopen behavior. Export templates are not installed here; follow WEB_EXPORT.md.
- Real playtime at a comfortable tapping rate. Tune toward 10–15 minutes including decisions/story; fast simulated active tapping is shorter.
- Your replacement illustrations on the smallest supported portrait viewport.

## Commit handoff

The repository began with untracked project/editor files. `.gitignore`, `.gitattributes` and VS Code setup have been retained. Review the whole initial project before committing; include `.gd.uid` and imported asset `.import` metadata but not the ignored `.godot/` cache. No commit, push, publication or deployment was performed.

Suggested commit message: `Build One More Flight campaign, mobile UI, content resources, and integration tests`.
