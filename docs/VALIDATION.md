# Validation and delivery — v0.3.1

Validated with Godot 4.7.2 stable on Intel macOS and the Compatibility renderer. The final v0.3.3 headless and graphical integration runs each report **10,827 checks, zero failures**. The editor import also completes successfully with no script/resource errors. The suite isolates SaveManager.save_path at `/tmp/one_more_flight_tests.json` before campaign actions and removes that file afterward. Player saves are not overwritten.

Coverage includes first-time offers; owned level increases; cap exclusion and direct-grant caps; unique weighted offers and category fallback; exhausted pool progression; required reward/event ordering and no skips; no reward savings deduction; exactly one event on even chapter days and cadence reset after relic selection; no consecutive event repeats; both outcomes of all eight events and exact event amplifier calculations; shared burst cap; fixed and milestone time budgets; loaded extension budgets; passive earnings limited to actual remaining time; interest, combo timeout, tap milestones and relic synergies; pause/settings navigation; settings persistence; v0.1 migration; pending decision disk round trips; duplicate-action rejection; complete campaigns and ending Continue; corrupt-save recovery.

The seeded 10,000-offer test chose a new ability for the first card 6,499 times (64.99%; acceptable range 63–67%). Unique-card checks run on every sample. The second and third cards use the same conditional category rule after removal; eligibility can change their available categories.

With three-day events and automatic milestones, full campaigns at 2/3/4 taps per second complete in 7/8/8, 6/6/7 and 5/5/6 chapter days respectively. Active work totals are 230/190/160 seconds. These accelerated results test reachability, not human session duration. See GAME_DESIGN.md for policy and balance limitations.

## Graphical checks

The graphical suite ran successfully on Intel Iris Plus OpenGL Compatibility. Main menu, ready/workday heart, reward selection/highlight, events, chapter story, relics and ending screens were captured. Responsive views cover physical widths 320, 360 (configured minimum), 390, 430 and 1024, all 844 pixels tall. Screenshots were visually inspected for wrapping, scrolling, contrast and overlap. Text wraps and NEW/LEVEL badges are visible. All three compact reward choices fit together on the tested phone views; wider views use three columns. Card-content bounds, visible choice bounds, and compact celebration height are checked automatically. The workday uses the original pixel heart, with no text inside. Logical button heights are checked at >=52 pixels; a 320-wide scaled window does not establish a physical mobile touch target guarantee. Existing chapter artwork and scene entry points are preserved; the shared theme and presentation are redesigned. Screenshots are temporary QA artifacts in `/tmp/omf_*` and `/tmp/one_more_flight_*`, not game assets.

The intentional invalid-JSON test emits expected recovery warnings for deliberately corrupted campaign/results files. Initial sandbox runs also logged macOS certificate/editor-settings access errors; the final desktop-permitted import and graphical run do not show those errors. Restricted runs can also report a platform certificate-access error, unrelated to this offline gameplay. No script errors or test failures remain.

## Outstanding manual checks

- Human click-through and comfortable tapping playtime, especially later chapters and shared-cap time builds.
- iPhone Safari and Android browser touch input, rapid taps versus scrolling, safe areas, orientation and address-bar resizing.
- Web export and browser-storage close/reopen behavior. Desktop Compatibility validation does not establish browser or physical-device behavior; follow WEB_EXPORT.md.
- More RNG seeds and reward strategies before finalizing provisional values or adjusting travel goals.

## Delivery

Feature branch: `feature/v0.3.3-seamless-flow`. Prior milestone/collection refinements were preserved in checkpoint `3d9e144` on the v0.3.1 branch before editing. The existing `v0.1-playable` tag is preserved at `d1702a14347445bb16b6173256fe265f80f5e8c3`. The v0.2 branch remains at `3799a91be9350968d3b5bace0f55ce5a67e4e948`. The v0.3 branch remains at `364179e`. The v0.3.3 implementation changes GameManager flow, FlightScreen readiness gating and the event interval only. SaveManager/results storage, economy amounts, content definitions, story Resources, scene files, artwork and existing card/event/relic designs are unchanged. No merge, push, publication or deployment is included.

Commit summary: remove between-day overviews, gate automatic workdays behind a visible/input-ready transition, and schedule events every third completed chapter day.

## v0.3 interaction regressions

Thirty immediate GUI mouse down/up pairs produce exactly 30 taps and $150 with base income. Timer text matches remaining time; every successful input creates earnings feedback, while optional particles are limited. Tests cover highlighting without mutation, save/load before confirmation, confirmation attempted twice, unchanged savings, reduced-motion persistence and heart behavior, and valid artwork/fallback resolution for all 26 content definitions. Presentation preferences use a separate `/tmp/one_more_flight_presentation_tests.cfg` and are removed after testing. The 64.99% seeded new-ability selection remains the v0.2 measurement; the milestone follow-up below records the current full-campaign results.

A real Web release export was attempted to `/tmp/one-more-flight-v03-web/index.html` and failed because `web_nothreads_debug.zip` and `web_nothreads_release.zip` are absent for Godot 4.7.2. No browser success is claimed. Install the matching templates and follow WEB_EXPORT.md to complete browser/device checks.

## v0.3.1 home and results validation

Headless and graphical suites both passed 10,650 checks with zero failures. New coverage: empty first launch; same gameplay heart texture at home; double activation guard; fresh starts after abandoned saved runs; no unfinished results; completed record written once; duplicate ending/restore and expired-history duplicate rejection; disk reload of results and completed chapter metadata; faster/slower/tied best comparisons; newest-first history limited to five; retained best after leaving history; missing/corrupt/malformed results data; fresh-start preservation of completed records; and per-chapter counts matching full-campaign simulations. Active/results/preference paths are isolated in `/tmp` before campaign actions and removed afterward.

Home screens with and without a record, results history, ending summary and existing gameplay/decision scenes were captured and inspected. The home best view fits without scrolling at 320×640, 360×640, 390×844, 430×932 and 1024×768. The usual 320/360/390/430/1024-width gameplay screenshots still pass layout bounds and touch-target checks. Results and narrative remain scrollable on short displays. Small home controls retain >=56 logical pixels of height. Native desktop rendering does not establish physical-device safe areas or browser touch behavior.

The Web release export now succeeds with the standard unchanged preset after installing the two matching official Web no-thread templates. The output is `/tmp/one-more-flight-v031-web/index.html` and its complete companion files. Export output was inspected for errors and required HTML/JS/WASM/PCK assets. No browser is connected to the UI tool, so an actual browser reload/storage test could not run. The temporary localhost preview server was stopped. No player saves or results were overwritten, and no hosting/deployment occurred. Earlier v0.3 missing-template notes describe the prior limitation; see WEB_EXPORT.md for the resolved setup.

Completed results are written at the third savings milestone, before the final story is read. Closing during that story therefore keeps the record. The original story and ending narrative remain unchanged. Completion dates are stored/displayed in UTC. A local attempt watermark assumes one active tab/session; multi-tab concurrent play is outside the requested scope.

## Automatic milestone follow-up

The milestone regression coverage remains passing in the v0.3.3 suite. Checks cover all three goals after interest, no completion during active or restored tapping, no early manual timer settlement, winning third-/sixth-day reward/event suppression, reduced goals and Passport, excess savings cleared at the next chapter, story checkpoint reloads without duplicate metadata, older reached-goal saves in ready/upgrades/event, post-work discounts/gifts reaching the goal, and one correct nine-day personal-best record with [3,3,3] chapter counts. Full campaign reachability simulations remain in place; changed RNG consumption from skipped winning-day choices explains the new seeded day counts, without balance tuning.

The obsolete buy_trip API and trip button are absent. The initial milestone follow-up removed the redundant “Bonuses:” list. Its expander has since been replaced by the always-visible collections and detail panels described below. No physical-device/browser behavior is inferred from desktop renders. Workday, content amounts, relics, result storage schema and story Resources are unchanged. The follow-up is preserved in checkpoint 3d9e144.

## Inline collection refinement

The UI-only follow-up passes **10,734 checks, zero failures**. Abilities and Keepsakes are always visible as icon/name rows. Collection tests cover both headings, name-only inline content, tapping an ability/relic, correct current/max level, original flavor/effect text for every upgrade, immutable campaign snapshots when opening details, Escape closure, suspended/restored real-time processing, and replacement by normal Pause/Save. Full-campaign reachability, milestone completion, save/load, event outcomes, relic persistence and personal-best tests remain passing with identical seeded results.

Graphical captures of representative collections, all 12 abilities plus six keepsakes, and detail panels were inspected at portrait widths 390 and 360. All item targets are at least 52 logical pixels high; long names and growing collections wrap, with normal vertical scrolling available. Effects and caps are shown only in the detail panel. Pause/Save is a compact transparent control. No `.tscn`, content, economy, manager, save or artwork files were changed by this UI refinement; prior uncommitted automatic-milestone work is preserved. Physical mobile/browser behavior remains unverified. Those refinements are preserved in checkpoint 3d9e144.

## v0.3.3 seamless flow and events

The final suite passes **10,827 checks, zero failures**, headless and graphical. New coverage checks days 1–9 (events only on 3/6/9), no repeat submissions, no earnings/time consumption during transitions, transition disk round trips, legacy pending-event migration, day-3/day-6 milestone priority, and event-day reset across all three chapters. A separate three-chapter run records exactly 18 workdays with [6,6,6] chapter counts; the faster nine-day fixture still verifies personal-best replacement. Combo/extension budgets reset at the new workday, while burst charges persist.

Actual timed UI checks verify a held mouse release cannot earn from the new heart, the screen is fully opaque before the timer starts, the 0.4-second fade/guard period does not consume work time, upgrade confirmation automatically begins the next session, pause/resume preserves the full next day, and stale callbacks cannot arm a rebuilt screen. Deterministic simulations call the same start_shift/advance_time/tap methods with live processing disabled; the UI readiness gate waits while processing is suspended. Native visual drivers resume ambient OS-focus pauses only during scripted autoplay; explicit pause tests retain normal behavior. Gameplay focus-pause logic was not changed.

The tapping transition, active tapping, upgrades, events, story/relics, collections, home and results screenshots were inspected at phone/desktop widths. No artwork, card design, theme or content effect changed. One preview shows Day X with a disabled heart; after the handoff, the same visible nodes enable input and display the full timer. No overview/start button remains in the ordinary loop or at chapter start.

The unchanged single-thread Web preset exported successfully to `/tmp/one-more-flight-v033-web/index.html` with HTML/JS/WASM/PCK companions. No browser is connected to the available UI tool (inventory empty), so in-browser runtime, storage reload and physical-device input/safe areas remain unverified. No publishing, hosting or merge was performed. Transition restores deliberately replay only the brief visual delay, never the previous reward/event; old settled ready states advance without replaying earlier days.

## v0.4 Cozy Pixel Arcade

The complete headless and native regression runs pass 10,837 checks with no failures. This includes the same three complete campaign simulations, 65/35 selection distribution, all event outcomes, automatic milestones, relic/reset persistence, isolated saves, seamless transitions and accurate personal-best records. No managers, gameplay/content Resources, or story text changed. Four new checks verify actual rendered Baloo font coordinates at 500/600/700/800, catching silent fallback to the default font weight.

Native screenshots cover home, Results, active gameplay/transition, collections and item details, rewards/selection, events, stories, relics, ending, Pause and Settings. Reward layouts are checked at 320/360/390/430 and 1024 logical widths, with scrolling and >=52 logical pixel targets retained. Paused overlays render fully opaque immediately; regular screen entrances retain their brief reduced-motion-aware fade. No new continuous animation or particles were added. Existing story illustrations remain intentionally calmer and less pixelated than the UI.

Godot 4.7.2 editor import and Compatibility native launch succeed. Single-thread Web release export succeeds at `/tmp/one-more-flight-v04-web/index.html`. Only intentional corrupt-file test warnings are expected. No physical-device or interactive browser runtime/performance validation was available; mobile safe areas, OS font fallback for decorative symbols and real browser performance remain manual checks. Accelerated simulation timings remain 230/190/160 seconds of active work at 2/3/4 taps per second; no human pacing claim or balance change.

## Split savings HUD refinement

Headless and native foundation runs pass 10,861 checks. Added HUD checks cover real tap earnings, existing goal discounts, 100% visual cap, goal crossing without consuming time/ending work, rendering without campaign mutation, reduced-motion fill, and large-currency layout at 320/390 logical widths. Portrait captures of ordinary savings, goal crossing and $1,234,567,890,123 were inspected; the final goal effect is a brief center-aligned sparkle burst without input interception. Native targeted captures use separate temporary saves. Import and runtime logs have no script/layout errors; only intentional corrupt-file regression warnings remain. Physical browser/device behavior remains a manual check. No economy/manager changes were made.
