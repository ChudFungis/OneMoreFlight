# Validation and delivery — v0.2

Validated with Godot 4.7.2 stable on Intel macOS and the Compatibility renderer. The final headless and graphical integration runs each report **10,253 checks, zero failures**. The editor import also completes successfully with no script/resource errors. The suite isolates SaveManager.save_path at `/tmp/one_more_flight_tests.json` before campaign actions and removes that file afterward. Player saves are not overwritten.

Coverage includes first-time offers; owned level increases; cap exclusion and direct-grant caps; unique weighted offers and category fallback; exhausted pool progression; required reward/event ordering and no skips; no reward savings deduction; exactly one event on even chapter days and cadence reset after relic selection; no consecutive event repeats; both outcomes of all eight events and exact event amplifier calculations; shared burst cap; fixed and milestone time budgets; loaded extension budgets; passive earnings limited to actual remaining time; interest, combo timeout, tap milestones and relic synergies; pause/settings navigation; settings persistence; v0.1 migration; pending decision disk round trips; duplicate-action rejection; complete campaigns and ending Continue; corrupt-save recovery.

The seeded 10,000-offer test chose a new ability for the first card 6,499 times (64.99%; acceptable range 63–67%). Unique-card checks run on every sample. The second and third cards use the same conditional category rule after removal; eligibility can change their available categories.

Full campaigns at 2/3/4 taps per second complete in 7/9/9, 5/5/7 and 5/5/6 chapter days respectively. Active work totals are 252/170/160 seconds. These accelerated results test reachability, not human session duration. See GAME_DESIGN.md for policy and balance limitations.

## Graphical checks

The graphical suite ran successfully on Intel Iris Plus OpenGL Compatibility. Reward and event screens were captured and visually inspected at physical widths 390, 360 (configured minimum) and 320 (additional scaled stress check), all 844 pixels tall. Text wraps, NEW/LEVEL badges are visible, long rewards scroll to the final card and Pause/Save, and gameplay retains the existing large tapping button. Logical button heights are checked at >=52 pixels; a 320-wide scaled window does not establish a physical mobile touch target guarantee. Existing artwork, theme and layout structure are preserved. Screenshots are temporary QA artifacts in `/tmp/omf_*` and `/tmp/one_more_flight_*`, not game assets.

The intentional invalid-JSON test emits one recovery warning. Initial sandbox runs also logged macOS certificate/editor-settings access errors; the final desktop-permitted import and graphical run do not show those errors. The restricted headless test still reports the platform certificate-access error, unrelated to this offline gameplay. No script errors or test failures remain.

## Outstanding manual checks

- Human click-through and comfortable tapping playtime, especially later chapters and shared-cap time builds.
- iPhone Safari and Android browser touch input, rapid taps versus scrolling, safe areas, orientation and address-bar resizing.
- Web export and browser-storage close/reopen behavior. Desktop Compatibility validation does not establish browser or physical-device behavior; follow WEB_EXPORT.md.
- More RNG seeds and reward strategies before finalizing provisional values or adjusting travel goals.

## Delivery

Feature branch: `feature/v0.2-gameplay-redesign`. The existing `v0.1-playable` tag is preserved at `d1702a14347445bb16b6173256fe265f80f5e8c3`. The pre-existing untracked `design/` directory is excluded from the implementation commit. No UI redesign, illustration replacement, push, publication or deployment is included.

Commit summary: implement v0.2 free weighted rewards, guaranteed positive events, bounded workday extensions, proposed content, compatible saves, simulations and portrait validation.
