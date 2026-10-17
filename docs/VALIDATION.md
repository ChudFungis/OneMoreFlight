# Validation and delivery — v0.3

Validated with Godot 4.7.2 stable on Intel macOS and the Compatibility renderer. The final headless and graphical integration runs each report **10,561 checks, zero failures**. The editor import also completes successfully with no script/resource errors. The suite isolates SaveManager.save_path at `/tmp/one_more_flight_tests.json` before campaign actions and removes that file afterward. Player saves are not overwritten.

Coverage includes first-time offers; owned level increases; cap exclusion and direct-grant caps; unique weighted offers and category fallback; exhausted pool progression; required reward/event ordering and no skips; no reward savings deduction; exactly one event on even chapter days and cadence reset after relic selection; no consecutive event repeats; both outcomes of all eight events and exact event amplifier calculations; shared burst cap; fixed and milestone time budgets; loaded extension budgets; passive earnings limited to actual remaining time; interest, combo timeout, tap milestones and relic synergies; pause/settings navigation; settings persistence; v0.1 migration; pending decision disk round trips; duplicate-action rejection; complete campaigns and ending Continue; corrupt-save recovery.

The seeded 10,000-offer test chose a new ability for the first card 6,499 times (64.99%; acceptable range 63–67%). Unique-card checks run on every sample. The second and third cards use the same conditional category rule after removal; eligibility can change their available categories.

Full campaigns at 2/3/4 taps per second complete in 7/9/9, 5/5/7 and 5/5/6 chapter days respectively. Active work totals are 252/170/160 seconds. These accelerated results test reachability, not human session duration. See GAME_DESIGN.md for policy and balance limitations.

## Graphical checks

The graphical suite ran successfully on Intel Iris Plus OpenGL Compatibility. Main menu, ready/workday heart, reward selection/highlight, events, chapter story, relics and ending screens were captured. Responsive views cover physical widths 320, 360 (configured minimum), 390, 430 and 1024, all 844 pixels tall. Screenshots were visually inspected for wrapping, scrolling, contrast and overlap. Text wraps and NEW/LEVEL badges are visible. All three compact reward choices fit together on the tested phone views; wider views use three columns. Card-content bounds, visible choice bounds, and compact celebration height are checked automatically. The workday uses the original pixel heart, with no text inside. Logical button heights are checked at >=52 pixels; a 320-wide scaled window does not establish a physical mobile touch target guarantee. Existing chapter artwork and scene entry points are preserved; the shared theme and presentation are redesigned. Screenshots are temporary QA artifacts in `/tmp/omf_*` and `/tmp/one_more_flight_*`, not game assets.

The intentional invalid-JSON test emits one recovery warning. Initial sandbox runs also logged macOS certificate/editor-settings access errors; the final desktop-permitted import and graphical run do not show those errors. Restricted runs can also report a platform certificate-access error, unrelated to this offline gameplay. No script errors or test failures remain.

## Outstanding manual checks

- Human click-through and comfortable tapping playtime, especially later chapters and shared-cap time builds.
- iPhone Safari and Android browser touch input, rapid taps versus scrolling, safe areas, orientation and address-bar resizing.
- Web export and browser-storage close/reopen behavior. Desktop Compatibility validation does not establish browser or physical-device behavior; follow WEB_EXPORT.md.
- More RNG seeds and reward strategies before finalizing provisional values or adjusting travel goals.

## Delivery

Feature branch: `feature/v0.3-ui-redesign`. The existing `v0.1-playable` tag is preserved at `d1702a14347445bb16b6173256fe265f80f5e8c3`. The v0.2 branch remains at `3799a91be9350968d3b5bace0f55ce5a67e4e948`. No gameplay manager, save manager, balance value, content definition or story Resource changed. No merge, push, publication or deployment is included.

Commit summary: redesign the v0.3 presentation with a pixel heart, shared theme, responsive collectible cards, illustrated events/relics, replaceable SVG placeholders, reduced motion and GUI regression checks.

## v0.3 interaction regressions

Thirty immediate GUI mouse down/up pairs produce exactly 30 taps and $150 with base income. Timer text matches remaining time; every successful input creates earnings feedback, while optional particles are limited. Tests cover highlighting without mutation, save/load before confirmation, confirmation attempted twice, unchanged savings, reduced-motion persistence and heart behavior, and valid artwork/fallback resolution for all 26 content definitions. Presentation preferences use a separate `/tmp/one_more_flight_presentation_tests.cfg` and are removed after testing. Full campaign results and 64.99% seeded new-ability selection remain exactly the v0.2 measurements.

A real Web release export was attempted to `/tmp/one-more-flight-v03-web/index.html` and failed because `web_nothreads_debug.zip` and `web_nothreads_release.zip` are absent for Godot 4.7.2. No browser success is claimed. Install the matching templates and follow WEB_EXPORT.md to complete browser/device checks.
