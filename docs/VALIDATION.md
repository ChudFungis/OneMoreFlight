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

## Travel suitcase collection

Headless and native foundation runs pass 10,881 checks. New coverage includes intentional empty state, ability acquisition and entrance eligibility, keepsake-only and mixed collections, multi-level inspection, persisted collection restoration, all-catalog deduplication, bounded scrolling and touch-target bounds. Existing popup tests still verify exact Resource effects, level caps, dismissal, clock suspension and unchanged campaign snapshots. The full three-chapter simulations, event outcomes, milestone completion, results and saves remain covered.

Portrait screenshots cover empty, abilities-only, keepsakes-only, mixed and all-catalog collections; internal scrolling reaches the lower compartment. Caption/lid spacing and small-collection overflow were refined after native inspection. The suitcase uses 56-pixel icon touch targets and a viewport capped at 128 logical pixels, with normal outer scrolling on short screens. No continuous idle loop or physics was added.

The standard single-thread Web export succeeds at `/tmp/one-more-flight-suitcase-web/index.html`. No gameplay managers or content Resources changed in the suitcase commit. Physical mobile/browser interaction and performance remain unverified; browser/device safe areas and scroll gestures remain manual checks. Existing story/illustration quality is unchanged. Earlier uncommitted copy/palette/HUD refinements were preserved separately in checkpoint a121bb2.

One native rerun intermittently failed the existing detail-dismissal/clock tests; the initial native run and subsequent unchanged rerun both passed all 10,881 checks. Headless runs passed consistently. This was not reproduced as a suitcase rendering/logic failure; native window focus and real mobile gesture behavior remain manual verification points.

## Collection code troubleshooting

Fixed FlightSuitcase.populate retaining old items, compartments and empty-state decorations on repeat calls. It now removes prior content and clears the button lookup before rendering the supplied collection. Added regressions for replacing a populated suitcase and returning to empty. The save/load UI test now rebuilds from restored state and compares IDs independent of catalog ordering, rather than checking the already-rendered buttons. The removed suitcase caption remains absent, with its layout preserved by a plain spacer.

Headless and native full-suite checks: 10,884 checks, zero failures. Godot import reports no parse/script errors. A separate native probe opened and dismissed the item modal with real cancel input 40 times without failure; the previously intermittent native focus-related test failure was not reproduced by that probe. Physical browser/device focus/gesture behavior remains unverified. No economy, resource IDs, progression or save format changed. All diagnostics use isolated temporary saves.

## Immediate goal completion

Owner-requested rule update: the goal-reaching tap now ends work immediately, rather than waiting out the timer. Passive earnings also stop at the crossing; advance_time caps passive elapsed time to avoid paying income for unplayed time. Both paths use the existing finish_shift settlement, counting one day and paying its interest once, then skipping rewards/events for the winning day. Above-goal legacy active saves settle on restore. The normal timer/extensions, tap formulas, relic/reset rules and results ledger remain.

Godot import succeeds; headless and native foundation runs each pass 10,978 checks with no script errors. Tests cover immediate wins across all three discounted goals, interest once, blocked subsequent taps, disk restore without duplicate completion, savings reset, a three-day completed-run score, passive crossing and legacy active-save normalization. Existing interest-at-timer-expiry tests still pass. Seeded simulations retain [7,8,8], [6,6,7], [5,5,6] chapter days at 2/3/4 taps per second; the stepped driver now reports 217.5/175.3/143.8 seconds of active work due to early endings. These are simulations, not measured human playtimes. Physical browser/device play remains unverified.


## Nine permanent chapter abilities

Godot 4.7.2 headless regression passes 11,106 checks with zero failures. New coverage verifies no old level/time/discount caps, the nine-item reward pool, 65/35 weighting (6,499 new first cards / 10,000 trials), Cabrito chance distribution and RNG save continuation, regular-only critical hits, Nicky growth across taps/days/saves and chapter reset, repeated music activations, Willow-before-interest settlement exactly once, and legacy roster/refill migration. Existing chapter flow, local records, pause, collection layout and full-campaign reachability remain covered. Intentional invalid-results/save recovery warnings remain expected.

Seed 12345, preference order facetime/tips/love/appointment/jar/team/flights, existing burst event alternatives and first offered keepsake:

| Taps/sec | Denver / Italy / Future days | Active work |
| --- | --- | --- |
| 2 | 9 / 10 / 9 | 279.0 s |
| 3 | 7 / 7 / 7 | 200.3 s |
| 4 | 7 / 6 / 6 | 177.2 s |

These are accelerated single-seed simulations, not measured human pacing. Goals are unchanged. Different choices/seeds and compounding interest can change the results. Extremely high music levels can sustain tapping until the finite chapter savings goal is reached; that is a consequence of the approved uncapped design.

The single-thread Web release export succeeds at ../ability-web/index.html with no script/export errors. A second editor import in this restricted local session cannot save global editor settings; initial import completed resource processing. The native graphical runner exits before producing output in this session, so new screenshots/visual QA and physical-device/browser interaction are not claimed. Headless layout checks at 320/360/390/430/1024 logical widths still run; current/next descriptions need phone review. The GitHub PR workflow independently repeats clean import, the suite and Web export before any release. No live publication is part of this branch preparation.

## Retired ability cleanup

Removed unused resources/upgrades/blessing.tres, cafecito.tres and empire.tres after verifying no active Resource preloads reference them. Removed inactive blessing multipliers from event presentation/settlement (power already returned zero outside the active catalog). Legacy-ID migration tests and artwork remain. Godot import succeeds; the current headless suite passes 11,106 checks, including legacy retired-ID migration. Existing user edits to story.tres and playlist.tres are preserved. The test run also reports story artwork case mismatches (Denver/Italy/Final versus lowercase filenames); these originate in the pre-existing local story edits and remain outstanding for case-sensitive/Web exports. Intentional corrupt-save/results warnings remain.

## Ability filename alignment

Renamed the nine active ability .tres files to title-based snake_case names and updated all FlightCatalog preload paths. Stable Resource IDs and artwork stems remain unchanged; no save migration is needed. User title/description/amount edits are preserved, including Willow's amount of 50. Two settlement assertions and the documented example now match that owner-edited value ($500 + $250 Willow, then 20% interest = $900). Import succeeds and all 11,092 headless checks pass. Existing story artwork casing warnings remain as noted above; no missing renamed ability paths or script errors were reported.

## One-second end-of-day presentation

Import succeeds; headless and native foundation runs pass 11,103 checks. Added coverage verifies a below-goal workday displays the input-blocking handoff before choices, freezes it during Pause, reveals exactly three existing free choices afterward, and preserves the settled campaign snapshot. Reduced motion retains the full one-second message without movement/fades. Existing immediate goal wins and mandatory reward/save behavior remain covered. The native 390 portrait transition capture was inspected for readable copy and layout. The normal timing budget is 0.15s entrance + 0.67s hold + 0.18s incoming screen fade; no extra gameplay phase or reward callback was added. Existing story artwork case warnings remain unrelated and unresolved; physical-device/browser timing remains a manual check.

## Framed HUD and ability-page footer

The shared SAVED/FLIGHT GOAL values now sit in a themed panel. Ability selection reuses a compact panel below confirmation with the completed workday's shift_clicks and the existing inspectable suitcase. Import succeeds; headless and native runs pass 11,145 checks. Tests verify actual savings/discounted goal values, the 30-click workday footer, all owned icons, and opening an item detail without changing the pending offer/campaign snapshot. Native portrait captures include the framed gameplay HUD and empty/populated footer, with outer-page and internal suitcase overflow inspected at phone widths. No economy or persistence fields changed. Existing story artwork casing warnings and physical-browser/device verification remain outstanding.

Separate tapping HUD refinement: headless suite passes 11,145 checks; native targeted captures at 390 and 320 widths verify separate framed values, captions outside/above the boxes, ExtraBold currency and large-number fitting. The reward footer is unchanged. Import/runtime report no script errors; the pre-existing story artwork casing warnings remain outside this change.

Four-box reward footer: Godot import and 11,146 headless checks pass. Native targeted captures at 390/320 widths were inspected for the two-by-two stat grid and accessible suitcase/scrolling. Tests retain exact currency/goal checks and verify four stat panels. No gameplay or save changes.

## Your Biggest Fan keepsake

Replaced the unlimited keepsake's tenth-tap payout with a 25% chance of one extra level on a confirmed ability choice. Stable save/art ID unlimited is retained. No recursive rolls, direct-grant bonuses or invalid/double-confirm rolls; Volaris extra levels use the same multiplicative discount rule. Successful results and RNG state persist through disk reload, with a bonus notice.

Godot 4.7.2 headless suite passes 11,557 checks with zero failures. The new deterministic chance trial produced 105 bonuses / 400 selections. Tests cover successful grants, unchanged direct grants, no-keepsake behavior, duplicate confirms, disk restore, the removed tenth-tap payout and compounded discounts. Existing day-end animation, framed HUD, nine-ability roster and local score checks pass. Only intentional corrupt-save/results warnings remain.

Updated seeded simulations (same preference order, existing event choices, first offered keepsake): 2 taps/sec completes [5,9,8] chapter days / 212.5 active seconds; 3 taps/sec [5,7,7] / 171.3 seconds; 4 taps/sec [4,6,6] / 160.0 seconds. These are simulated, not measured human session lengths. Physical phone playtesting remains required. GitHub's release workflow independently repeats clean import, tests and Web export before deploying.

## Automatic positive/negative events (snapshot v5)

The eight existing events now have one fixed automatic outcome: four positive and four negative. No alternate outcomes or temporary tap-charge code remains. GameManager applies/persists the result before the event UI is revealed; the only outcome control is Continue, alongside normal Pause/Save navigation. Positive gifts receive the earnings multiplier; penalties do not and cannot exceed savings. Extra workday seconds and multiplicative ticket discounts persist within a chapter and reset at the next one. Winning events remain visible until acknowledged.

Godot 4.7.2 headless regression passes 11,636 checks with zero failures. Tests cover all eight exact outcomes, one Continue button, redraw/reload idempotency, repeated acknowledgement, no debt at low/zero balances, stacking event/ability/keepsake discounts, lasting time, chapter resets, winning-event reload/acknowledgement and legacy v4 choice migration with discarded boost charges. Existing chance, nine-ability, local-result, layout and navigation checks remain. Only the intentional corrupt-save/results warnings are present.

Current single-seed full-campaign simulations: 2 taps/sec completes [5,9,8] chapter days / 214.5 active seconds; 3 taps/sec [5,7,7] / 179.3 seconds; 4 taps/sec [5,6,6] / 156.5 seconds. These use the real rules and automatic events; they are not human pacing measurements. Goals/ability amounts were not retuned.

New native screenshots and physical mobile-browser checks are not claimed because graphical launch is unavailable in this session. The existing headless portrait/desktop layout checks still run. GitHub's PR workflow independently verifies clean import, tests and single-thread Web export before the approved release.
