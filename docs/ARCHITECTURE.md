# Gameplay architecture

The original four autoloads and persistent `Main` scene remain. The renderer remains Compatibility. No dependency or global event bus was added.

## Ownership

- **GameManager**: campaign state, income rules, weighted free offers, scheduled events, travel purchases, chapters and relics. `advance_time(delta)` is shared by real-time processing and deterministic tests. UI never calculates rewards. `changed` updates counters, `phase_changed` rebuilds the decision view, `earned` creates feedback, and `notice` supports gameplay notices.
- **SceneManager**: original Screens/Overlays hosts, navigation, pause/resume and Settings return destination. Pausing freezes the tree, saves progress and preserves the game scene. All overlays process while paused. Browser fullscreen is not applied automatically.
- **SaveManager**: validated audio/display settings and a versioned campaign dictionary in `user://save_data.json`. It reports open/write errors. Campaign numeric values, IDs and phases are validated by GameManager on restore. Saving is a local JSON file, not cloud synchronization or an atomic backup system.
- **AudioManager**: Music/SFX buses and saved volume levels, ready for future streams. No audio assets are required to play.

## Campaign flow

`ready → work → upgrades → [even-day event] → ready`. A trip can be purchased only from ready after required choices and only with sufficient unspent money. The player chooses when to travel, not just when a lifetime-earned counter passes a threshold.

A purchased trip leads to `story → relic → ready` in the next chapter. Chapter 3 instead leads to `story → ending`. Completion is saved on the final trip; continuing during its story still shows that story. The internal restore API can still restore an ending for compatibility; the home screen deliberately offers only a fresh start.

The snapshot includes chapter, money, chapter/total completed days, upgrades, relics, completed chapters, completion status, phase, selected offers/event, ticket discount, remaining time, shift click count, combo, temporary click charges, pending-event state, last event ID, and extension consumed. Offers are persisted to prevent refresh rerolls. It resumes the saved remaining time without offline earnings; up to two seconds of work can be lost on an abrupt browser termination. Explicit pause/menu actions save immediately.

## Content and presentation

`FlightDefinition` is a small custom Resource for upgrades, relics and events. Definitions have stable IDs, descriptions, effect names, amounts, level caps, choice labels, legacy price metadata and optional textures/alternate outcomes. `FlightCatalog` explicitly preloads them so exports include the content; no runtime directory scan is required. Upgrade quantities come from definitions through `power(id)`; timing caps and combo cadence are explicit rules in GameManager. New effect types require an explicit implementation and tests, not a generic expression language.

`FlightBalance` centralizes economy parameters. `FlightStory` holds editable prose. The screen script selects a view from its scene export. It uses one set of mobile layout/card/art helpers, a shared theme, containers, word wrapping and scrolling. Long choices remain accessible below the fold. The three old UI scripts are lightweight compatibility wrappers; current scenes use FlightScreen directly. `game_over.tscn` is retained as an old navigation alias; chapter endings now live in the campaign flow.

Every touch target is at least 52 logical pixels high; the heart hit area is 250. Touch is emulated as mouse input once, so income is attached only to the button's pressed signal (not simultaneously to touch and mouse events). Short fades, image compression, floating labels, card highlights and celebration banners use built-in Tweens/Controls. Progress and timer labels render the current state directly. No shaders, portraits, network services, or desktop-only gameplay input are required.

## v0.2 save compatibility

Campaign snapshots now use game_version 2; the retained internal restore API accepts versions 1 and 2 (including JSON numeric version values). v0.1 levels, bursts and work time are clamped to v0.2 bounds. Stable IDs, savings, chapters, discounts and relics are preserved. Old shields are retired; owned blessing levels become the positive event amplifier. Legacy team levels become time extensions. A legacy shop becomes one mandatory free reward, retaining eligible offered IDs; if none remain, generate eligible replacements. A legacy event is retained and queued after its free reward. Previously purchased legacy shop items cannot be reconstructed; one free reward is allowed on migration. Old ready saves remain ready; prior days are not replayed. Migration is written by the next save/decision. No offline earnings are introduced.

Pending events are selected and persisted when work finishes, before the reward. Selecting the reward clears all offers and saves the next phase. Resolving the event clears pending state and saves ready. Stale callbacks cannot buy a second card, resolve an event twice, or travel before choices finish. An exhausted pool skips only the impossible reward, retaining any due event.

## v0.3 presentation

No GameManager, SaveManager, economy Resources or story content changed. Existing scene entry points remain; FlightScreen builds local components. FlightStyle provides the shared theme and a separate reduced-motion preference. FlightArt resolves explicit textures and stable-ID paths with a fallback. No autoload or dependencies were added.

The heart is a normal Button with a transparent style and an input-ignoring image; only its pressed signal calls tap. Scaling affects the image, keeping the hit rectangle fixed. An independent UI RNG positions earnings without consuming the gameplay RNG. Every successful tap uses the earned amount for its label; particles are occasional and suppressed during heavy input. Labels expire after 0.55 seconds.

Reward and relic cards highlight locally, then one Confirm action calls the existing GameManager action synchronously. It persists before any outcome animation. Highlight state is deliberately not saved; loading an unconfirmed choice shows the same offers with no selection. Rebuilding clears local selection and stale confirms do nothing. Animation callbacks only remove visual nodes, never award earnings or rewards.

At logical widths >=720, choice cards form three columns with illustrations above text; narrower windows show all three compact illustrated rows together, with scrolling retained as an overflow fallback. 20-pixel side gutters and 28-pixel vertical gutters provide conservative phone spacing; physical safe-area behavior still requires browser/device validation.

## v0.3.1 home and completed results

The home heart reuses the exact gameplay texture and animation functions. Its optional action calls new_game directly, with a per-screen guard against duplicate activation. Continue/New Game/Quit and confirmation dialogs are removed from home. Existing mid-game saves, pauses and Settings remain. Startup registers the home screen; loading the save dictionary never automatically restores a run. Results uses a local FlightScreen view, so no new scene host, autoload or event bus is needed.

SaveManager owns a small FlightResults instance with its own `user://results.json`. It loads independently of progression. Starting a run allocates and saves a monotonically increasing attempt number, and resets all run state. GameManager snapshots add run_attempt, chapter_days and run_new_best; older snapshots default these fields safely. Trip purchases capture each chapter's day count. Only the existing full-campaign completion boundary (successful third ticket purchase with all chapters completed) writes a completed record. The final story remains in place; entering the ending retries an earlier results write if needed.

The ledger stores the latest five completions newest first and a separate all-time best; fewer workdays is better and equal scores do not replace the best. A persisted last-recorded-attempt watermark prevents duplicate completion writes, even after a run drops out of recent history. This is a local, single-session ledger, not a multi-tab synchronization system. A corrupt/missing file produces safe empty defaults; valid fields and records are checked. Records use UTC completion timestamps. Temp-file writing plus rename avoids replacing a valid ledger with a partially written document. Storage errors remain visible with a retry on the ending screen.

The four original autoloads remain. No earnings, timer, reward eligibility, events, relic effects, goals or chapter transitions were rebalanced. Completed chapter indices are now normalized from JSON numeric values before membership checks, so disk-restored completion metadata is retained. No historical records are fabricated from an unfinished campaign; v0.3 has no completed history to import automatically.
