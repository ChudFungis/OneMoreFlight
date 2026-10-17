# Gameplay architecture

The original four autoloads and persistent `Main` scene remain. The renderer remains Compatibility. No dependency or global event bus was added.

## Ownership

- **GameManager**: campaign state, income rules, weighted free offers, scheduled events, savings milestones, chapters and relics. `advance_time(delta)` is shared by real-time processing and deterministic tests. UI never calculates rewards. `changed` updates counters, `phase_changed` rebuilds the decision view, `earned` creates feedback, and `notice` supports gameplay notices.
- **SceneManager**: original Screens/Overlays hosts, navigation, pause/resume and Settings return destination. Pausing freezes the tree, saves progress and preserves the game scene. All overlays process while paused. Browser fullscreen is not applied automatically.
- **SaveManager**: validated audio/display settings and a versioned campaign dictionary in `user://save_data.json`. It reports open/write errors. Campaign numeric values, IDs and phases are validated by GameManager on restore. Saving is a local JSON file, not cloud synchronization or an atomic backup system.
- **AudioManager**: Music/SFX buses and saved volume levels, ready for future streams. No audio assets are required to play.

## Campaign flow

`transition → work → [milestone: story | upgrades → optional third-day event → transition]`. Workday earnings and interest settle before checking current savings against the discounted chapter goal. A reached milestone enters the story immediately and skips that day’s upgrade/event. Below-goal days retain the usual choices and schedule. A discount reward or event gift that reaches the milestone after work also enters the story immediately.

A reached milestone leads to `story → relic → transition` in the next chapter. Chapter 3 instead leads to `story → ending`. Completion is saved on the final trip; continuing during its story still shows that story. The internal restore API can still restore an ending for compatibility; the home screen deliberately offers only a fresh start.

The snapshot includes chapter, money, chapter/total completed days, upgrades, relics, completed chapters, completion status, phase, selected offers/event, ticket discount, remaining time, shift click count, combo, temporary click charges, pending-event state, last event ID, and extension consumed. Offers are persisted to prevent refresh rerolls. It resumes the saved remaining time without offline earnings; up to two seconds of work can be lost on an abrupt browser termination. Explicit pause/menu actions save immediately.

## Content and presentation

`FlightDefinition` is a small custom Resource for upgrades, relics and events. Definitions have stable IDs, descriptions, effect names, amounts, level caps, choice labels, legacy price metadata and optional textures/alternate outcomes. `FlightCatalog` explicitly preloads them so exports include the content; no runtime directory scan is required. Upgrade quantities come from definitions through `power(id)`; timing caps and combo cadence are explicit rules in GameManager. New effect types require an explicit implementation and tests, not a generic expression language.

`FlightBalance` centralizes economy parameters. `FlightStory` holds editable prose. The screen script selects a view from its scene export. It uses one set of mobile layout/card/art helpers, a shared theme, containers, word wrapping and scrolling. Long choices remain accessible below the fold. The three old UI scripts are lightweight compatibility wrappers; current scenes use FlightScreen directly. `game_over.tscn` is retained as an old navigation alias; chapter endings now live in the campaign flow.

Every touch target is at least 52 logical pixels high; the heart hit area is 250. Touch is emulated as mouse input once, so income is attached only to the button's pressed signal (not simultaneously to touch and mouse events). Short fades, image compression, floating labels, card highlights and celebration banners use built-in Tweens/Controls. Progress and timer labels render the current state directly. No shaders, portraits, network services, or desktop-only gameplay input are required.

## v0.2 save compatibility

Campaign snapshots now use game_version 3; the retained internal restore API accepts versions 1, 2 and 3 (including JSON numeric version values). v0.1 levels, bursts and work time are clamped to v0.2 bounds. Stable IDs, savings, chapters, discounts and relics are preserved. Old shields are retired; owned blessing levels become the positive event amplifier. Legacy team levels become time extensions. A legacy shop becomes one mandatory free reward, retaining eligible offered IDs; if none remain, generate eligible replacements. A legacy event is retained and queued after its free reward. Previously purchased legacy shop items cannot be reconstructed; one free reward is allowed on migration. Old ready saves enter the automatic transition; already settled decisions are not replayed. Migration is written by the next save/decision. No offline earnings are introduced.

Pending events are selected and persisted when work finishes, before the reward. Selecting the reward clears all offers and saves the next phase. Resolving the event clears pending state and saves the next transition. Stale callbacks cannot buy a second card, resolve an event twice, or travel before choices finish. An exhausted pool skips only the impossible reward, retaining any due event.

## v0.3 presentation

No GameManager, SaveManager, economy Resources or story content changed. Existing scene entry points remain; FlightScreen builds local components. FlightStyle provides the shared theme and a separate reduced-motion preference. FlightArt resolves explicit textures and stable-ID paths with a fallback. No autoload or dependencies were added.

The heart is a normal Button with a transparent style and an input-ignoring image; only its pressed signal calls tap. Scaling affects the image, keeping the hit rectangle fixed. An independent UI RNG positions earnings without consuming the gameplay RNG. Every successful tap uses the earned amount for its label; particles are occasional and suppressed during heavy input. Labels expire after 0.55 seconds.

Reward and relic cards highlight locally, then one Confirm action calls the existing GameManager action synchronously. It persists before any outcome animation. Highlight state is deliberately not saved; loading an unconfirmed choice shows the same offers with no selection. Rebuilding clears local selection and stale confirms do nothing. Animation callbacks only remove visual nodes, never award earnings or rewards.

At logical widths >=720, choice cards form three columns with illustrations above text; narrower windows show all three compact illustrated rows together, with scrolling retained as an overflow fallback. 20-pixel side gutters and 28-pixel vertical gutters provide conservative phone spacing; physical safe-area behavior still requires browser/device validation.

## v0.3.1 home and completed results

The home heart reuses the exact gameplay texture and animation functions. Its optional action calls new_game directly, with a per-screen guard against duplicate activation. Continue/New Game/Quit and confirmation dialogs are removed from home. Existing mid-game saves, pauses and Settings remain. Startup registers the home screen; loading the save dictionary never automatically restores a run. Results uses a local FlightScreen view, so no new scene host, autoload or event bus is needed.

SaveManager owns a small FlightResults instance with its own `user://results.json`. It loads independently of progression. Starting a run allocates and saves a monotonically increasing attempt number, and resets all run state. GameManager snapshots add run_attempt, chapter_days and run_new_best; older snapshots default these fields safely. Chapter milestones capture each chapter’s day count. Only the third milestone with all chapters completed writes a completed record. The final story remains in place; entering the ending retries an earlier results write if needed.

The ledger stores the latest five completions newest first and a separate all-time best; fewer workdays is better and equal scores do not replace the best. A persisted last-recorded-attempt watermark prevents duplicate completion writes, even after a run drops out of recent history. This is a local, single-session ledger, not a multi-tab synchronization system. A corrupt/missing file produces safe empty defaults; valid fields and records are checked. Records use UTC completion timestamps. Temp-file writing plus rename avoids replacing a valid ledger with a partially written document. Storage errors remain visible with a retry on the ending screen.

The four original autoloads remain. No earnings, timer, reward eligibility, events, relic effects, goals or chapter transitions were rebalanced. Completed chapter indices are now normalized from JSON numeric values before membership checks, so disk-restored completion metadata is retained. No historical records are fabricated from an unfinished campaign; v0.3 has no completed history to import automatically.

## Automatic savings milestones

GameManager checks `_complete_chapter()` after finish_shift increments day counts and pays interest, before generating random offers/events. Active shifts cannot finish early, including a restored shift already above goal. Savings are a milestone, with no ticket deduction; the existing relic-choice transition clears all money, so excess never carries forward. Winning-day pending decisions are cleared before the story snapshot is saved. Story/relic/ending phases and completed-chapter IDs guard against duplicate transitions. The same per-run ledger guard still prevents duplicate personal-best entries.

Restore also advances older ready/upgrade/event snapshots whose settled workday already reached the goal, without adding a day or paying interest again. The obsolete buy_trip API and UI button are removed. The former ability expander has been replaced by always-visible Abilities/Keepsakes collections: flat icon/name rows wrap in a flow layout and open local item details. The redundant “Bonuses:” list and duplicated combo text were removed. Existing combo/burst indicators remain.

## Inline collections and item details

FlightScreen builds lightweight, >=52-logical-pixel item rows from existing FlightArt mappings; names wrap without inline effect descriptions. Pause/Save uses the existing navigation action with a compact, transparent presentation. No data Resources, economy rules, progression or persistence were changed for this refinement.

FlightItemDetails is a local Control added to the existing overlay host, not an autoload or new navigation framework. It shows Resource flavor/effect prose, owned level and level cap, or permanent keepsake status. Cabrito instead shows refill acquisitions and remaining shared charges. The panel temporarily suspends GameManager's real-time processing without changing campaign state or saving, blocks underlying input, and restores the prior processing state on exit. Escape closes it before navigation receives the input. Existing focus-loss Pause/Save can replace it safely. Popup state is intentionally transient.

## v0.3.3 seamless workdays

New games, ordinary reward/event completion, and relic selection now save a `transition` phase instead of returning to an overview. FlightScreen renders the existing tapping layout with the heart disabled and a short Day X indicator. After 0.4 seconds and an input-release frame, it calls the same GameManager.start_shift used by deterministic tests. The already-visible screen is reused when work starts, avoiding a second fade while the timer is running. No separate countdown/start button is added.

A local rebuild generation invalidates stale transition callbacks. The handshake waits for completed entrance opacity/layout, no overlay, an unpaused playing state and released mouse/accept input. Pause and item details therefore cannot consume the next workday's time. Only GameManager initializes time, charges/combo budgets and the work phase; UI never awards income. A saved transition reloads its brief presentation delay without repeating the previous reward/event. Active work restores its saved remaining time as before.

Event eligibility is completed chapter days modulo event_interval == 0; both balance defaults and balance.tres set the interval to 3. The existing random event selection, non-repeat preference and positive rewards are unchanged. Events are selected/saved when work settles and displayed after the reward; milestones take priority before either offer. Chapter day/pending state resets are unchanged. Pending old-version decisions are normalized to days 3/6/9; an obsolete even-day event is dismissed without replaying its reward. Existing completed results remain separate and unchanged.

## v0.4 presentation

Only FlightStyle, FlightScreen, FlightArt and FlightItemDetails change at runtime. Locally bundled Baloo 2 variations and the inherited theme cover all screen entry points; no scene or autoload changes. Pressed button styles move content padding and collapse hard shadow depth without moving the touch rectangle. Release tweens affect color only. Small utility buttons share pixel icons and transparent resting surfaces. Existing item rows and modal processing suspension remain. No manager, gameplay resource, story or save schema changed.

The gameplay savings HUD is presentation-only: FlightScreen reads savings and the discounted goal, renders separate values, and interpolates only the ProgressBar's visual value. Its goal-crossing flag and tweens are local/transient, reset on rebuild and excluded from saves. No animation callback changes money, time, rewards or progression.

## Travel suitcase presentation

FlightSuitcase is a reusable local VBoxContainer, not an autoload. It receives current upgrade/relic collections, builds deduplicated stable-ID icon buttons and emits item_inspected(item, relic). FlightScreen forwards that signal to its retained details modal. A bounded internal ScrollContainer keeps the collection compact. Deterministic artwork-only rotation and short entrance Tweens never consume GameManager RNG or alter hit rectangles. Case chrome is drawn from shared theme tokens; all item images still use FlightArt. No managers, gameplay Resources, save schema or scene entry points changed.
