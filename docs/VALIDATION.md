# Validation and delivery — v0.3.1

Validated with Godot 4.7.2 stable on Intel macOS and the Compatibility renderer. The final headless and graphical integration runs each report **10,650 checks, zero failures**. The editor import also completes successfully with no script/resource errors. The suite isolates SaveManager.save_path at `/tmp/one_more_flight_tests.json` before campaign actions and removes that file afterward. Player saves are not overwritten.

Coverage includes first-time offers; owned level increases; cap exclusion and direct-grant caps; unique weighted offers and category fallback; exhausted pool progression; required reward/event ordering and no skips; no reward savings deduction; exactly one event on even chapter days and cadence reset after relic selection; no consecutive event repeats; both outcomes of all eight events and exact event amplifier calculations; shared burst cap; fixed and milestone time budgets; loaded extension budgets; passive earnings limited to actual remaining time; interest, combo timeout, tap milestones and relic synergies; pause/settings navigation; settings persistence; v0.1 migration; pending decision disk round trips; duplicate-action rejection; complete campaigns and ending Continue; corrupt-save recovery.

The seeded 10,000-offer test chose a new ability for the first card 6,499 times (64.99%; acceptable range 63–67%). Unique-card checks run on every sample. The second and third cards use the same conditional category rule after removal; eligibility can change their available categories.

Full campaigns at 2/3/4 taps per second complete in 7/9/9, 5/5/7 and 5/5/6 chapter days respectively. Active work totals are 252/170/160 seconds. These accelerated results test reachability, not human session duration. See GAME_DESIGN.md for policy and balance limitations.

## Graphical checks

The graphical suite ran successfully on Intel Iris Plus OpenGL Compatibility. Main menu, ready/workday heart, reward selection/highlight, events, chapter story, relics and ending screens were captured. Responsive views cover physical widths 320, 360 (configured minimum), 390, 430 and 1024, all 844 pixels tall. Screenshots were visually inspected for wrapping, scrolling, contrast and overlap. Text wraps and NEW/LEVEL badges are visible. All three compact reward choices fit together on the tested phone views; wider views use three columns. Card-content bounds, visible choice bounds, and compact celebration height are checked automatically. The workday uses the original pixel heart, with no text inside. Logical button heights are checked at >=52 pixels; a 320-wide scaled window does not establish a physical mobile touch target guarantee. Existing chapter artwork and scene entry points are preserved; the shared theme and presentation are redesigned. Screenshots are temporary QA artifacts in `/tmp/omf_*` and `/tmp/one_more_flight_*`, not game assets.

The intentional invalid-JSON test emits expected recovery warnings for deliberately corrupted campaign/results files. Initial sandbox runs also logged macOS certificate/editor-settings access errors; the final desktop-permitted import and graphical run do not show those errors. Restricted runs can also report a platform certificate-access error, unrelated to this offline gameplay. No script errors or test failures remain.

## Outstanding manual checks

- Human click-through and comfortable tapping playtime, especially later chapters and shared-cap time builds.
- iPhone Safari and Android browser touch input, rapid taps versus scrolling, safe areas, orientation and address-bar resizing.
- Web export and browser-storage close/reopen behavior. Desktop Compatibility validation does not establish browser or physical-device behavior; follow WEB_EXPORT.md.
- More RNG seeds and reward strategies before finalizing provisional values or adjusting travel goals.

## Delivery

Feature branch: `feature/v0.3.1-home-screen`. The existing `v0.1-playable` tag is preserved at `d1702a14347445bb16b6173256fe265f80f5e8c3`. The v0.2 branch remains at `3799a91be9350968d3b5bace0f55ce5a67e4e948`. The v0.3 branch remains at `364179e`. GameManager and SaveManager gained completion metadata/results ownership only; no economy values, content definitions, story Resources, scene files, workday feedback or existing card/event/relic visuals changed. No merge, push, publication or deployment is included.

Commit summary: replace the home menu with a fresh-start heart, local personal best and five-run results, with duplicate-safe completion records and ending summaries.

## v0.3 interaction regressions

Thirty immediate GUI mouse down/up pairs produce exactly 30 taps and $150 with base income. Timer text matches remaining time; every successful input creates earnings feedback, while optional particles are limited. Tests cover highlighting without mutation, save/load before confirmation, confirmation attempted twice, unchanged savings, reduced-motion persistence and heart behavior, and valid artwork/fallback resolution for all 26 content definitions. Presentation preferences use a separate `/tmp/one_more_flight_presentation_tests.cfg` and are removed after testing. Full campaign results and 64.99% seeded new-ability selection remain exactly the v0.2 measurements.

A real Web release export was attempted to `/tmp/one-more-flight-v03-web/index.html` and failed because `web_nothreads_debug.zip` and `web_nothreads_release.zip` are absent for Godot 4.7.2. No browser success is claimed. Install the matching templates and follow WEB_EXPORT.md to complete browser/device checks.

## v0.3.1 home and results validation

Headless and graphical suites both passed 10,650 checks with zero failures. New coverage: empty first launch; same gameplay heart texture at home; double activation guard; fresh starts after abandoned saved runs; no unfinished results; completed record written once; duplicate ending/restore and expired-history duplicate rejection; disk reload of results and completed chapter metadata; faster/slower/tied best comparisons; newest-first history limited to five; retained best after leaving history; missing/corrupt/malformed results data; fresh-start preservation of completed records; and per-chapter counts matching full-campaign simulations. Active/results/preference paths are isolated in `/tmp` before campaign actions and removed afterward.

Home screens with and without a record, results history, ending summary and existing gameplay/decision scenes were captured and inspected. The home best view fits without scrolling at 320×640, 360×640, 390×844, 430×932 and 1024×768. The usual 320/360/390/430/1024-width gameplay screenshots still pass layout bounds and touch-target checks. Results and narrative remain scrollable on short displays. Small home controls retain >=56 logical pixels of height. Native desktop rendering does not establish physical-device safe areas or browser touch behavior.

The Web release export now succeeds with the standard unchanged preset after installing the two matching official Web no-thread templates. The output is `/tmp/one-more-flight-v031-web/index.html` and its complete companion files. Export output was inspected for errors and required HTML/JS/WASM/PCK assets. No browser is connected to the UI tool, so an actual browser reload/storage test could not run. The temporary localhost preview server was stopped. No player saves or results were overwritten, and no hosting/deployment occurred. Earlier v0.3 missing-template notes describe the prior limitation; see WEB_EXPORT.md for the resolved setup.

Completed results are written at the existing successful third-trip completion boundary, before the final story is read. Closing during that story therefore keeps the record. The original story and ending narrative remain unchanged. Completion dates are stored/displayed in UTC. A local attempt watermark assumes one active tab/session; multi-tab concurrent play is outside the requested scope.
