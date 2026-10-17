# Version 0.3 — presentation system

The game pairs chunky original pixel objects with a warm, modern interface: cream background, warm-white cards, blush borders, dusty-rose text, burgundy actions and restrained shadows. Godot's readable bundled default font avoids a heavy pixel font or additional dependency.

## Components and scene reuse

No `.tscn` files were replaced or modified. Existing main, game, main menu, settings, pause and ending entry points retain their persistent screen/overlay hosts and four autoloads.

- `scripts/ui/main.gd` applies the shared theme and loads the presentation preference.
- `scripts/ui/flight_style.gd` centralizes colors, shapes, spacing and principal transition durations; its ConfigFile stores only Reduced motion.
- `scripts/ui/flight_art.gd` resolves explicit textures and stable filenames, preserves aspect ratios and supplies fallback art.
- `scripts/ui/flight_screen.gd` builds the local heart, choice cards, event scenes, status details and short feedback animations.

The workday's text-free heart has a fixed 250-pixel logical hit area. Only its image compresses and springs back, so fast taps do not chase a moving input target. The existing pressed signal calls GameManager.tap once. Earnings labels use the earned signal's actual amount, rendered to cents; UI randomness never consumes campaign RNG. Small optional sparkles appear every sixth successful tap, with a stronger combo tint. Floating labels expire quickly, and optional particles are suppressed during heavy input.

Workday status prioritizes destination/chapter/day, savings goal, compact progress, remaining seconds, heart, combo and burst count. Abilities and Keepsakes are always visible as light icon/name collections, with effects available on tap.

Upgrade/relic choices use three compact illustrated rows on phones, or three columns at logical widths >=720. All offered cards remain visible together at the tested portrait sizes. Every card is a touch target; tapping highlights it and enables one confirmation. Other cards dim. Confirmation calls the existing action and persists immediately; short celebrations never own gameplay state. A reload before confirmation restores the same mandatory offer without a highlight. A reload after confirmation restores the committed next phase.

Event scenes retain the original short prose and choices. Reward lines show gifts including the current event amplifier/earnings relic, and burst additions including the shared charge capacity. A single-outcome definition uses Continue. Relics use richer cards, larger art and a permanent-effect badge; the selected relic gets a brief extra sparkle celebration. Travel keeps the existing story sequence and adds a compact banner.

Reduced motion in Settings suppresses positional/scaling/card-entry animation, tint pulses and optional sparkles. Short opacity-only feedback remains. The preference lives in `user://presentation.cfg`, separate from the unchanged campaign save schema. Menus remain responsive while gameplay is paused.

## Artwork

New directories: `assets/art/heart/`, `events/`, and `ui/`. Existing `upgrades/` and `relics/` now contain an individual square SVG for every stable content ID; existing `story/` placeholders are unchanged. There are 29 new SVGs: one heart, 12 upgrade illustrations, eight event illustrations, six relic illustrations and two reusable decorations. See ARTWORK.md for every filename, recommended dimensions and the PNG/WebP replacement workflow.

## Practical limits

During v0.3, no browser build could be produced because matching Godot 4.7.2 Web templates were missing; v0.3.1 resolves that export limitation. The existing Compatibility, single-thread preset remains unchanged. Native desktop GUI tests do not establish Safari storage, input latency, notch safe areas or physical touch-target sizes. Conservative 20-pixel side/28-pixel vertical gutters and scrolling are in place; validate real device safe areas before release. 320-wide rendering is a stress check below the configured desktop minimum of 360. Future artwork and significantly longer localized text should be checked again at minimum width. No portraits, custom soundtrack or new story prose were generated.

## v0.3.1 home and results

The home screen now centers the existing pixel heart under “One More Flight” and “Every tap brings us closer.” Tapping starts fresh in one step. A compact best-adventure panel and small trophy Results/gear Settings controls replace the old menu buttons. Home content is centered within 520 logical pixels on wide windows and fits the tested portrait viewports without scrolling. Missing results use an inviting first-record message.

Your Adventures shows the retained personal best, the newest five completed runs, attempt IDs, UTC dates and per-chapter days when available. Hearts mark scores tied with the current best. The final summary leads with actual workdays and a new-best badge when earned, followed by the unchanged illustration/narrative and Home/Start another adventure actions. Existing workday and decision visuals are unchanged. Only the home heart's optional action required a small shared-component extension; the gameplay action remains the default.

Two new original pixel icons are `assets/art/ui/trophy.svg` and `gear.svg`. The earlier missing-template limitation was resolved during this iteration by downloading the official matching Web templates. Web release export succeeds; a browser was not connected to the test tool, so browser storage and physical device checks remain outstanding.

## Collection UI refinement

The large “Your abilities & keepsakes” button is removed. Separate Abilities and Keepsakes sections use existing art at 24 logical pixels, burgundy name labels and transparent row hit areas. The flow layout wraps vertically as items accumulate; long names wrap within the row. Empty collections show “None yet.” The former overview/start CTA is removed in v0.3.3; the existing heart starts automatically after decisions. Pause/Save is a compact, transparent 52-pixel target.

Tapping a collected item opens FlightItemDetails: its name, owned level/max level (or permanent/refill status), original flavor line and exact Resource effect/caps are shown in a compact scrollable panel. Effects are not duplicated inline. Close, outside tap and Escape dismiss it. The workday clock is held while reading without awarding income, changing campaign phase or saving. Existing artwork, theme, gameplay formulas, content and reward probabilities remain unchanged.

## v0.3.3 flow refinement

The existing tapping layout is displayed directly between workdays and after relic selection; chapter overview artwork and its manual start action no longer interrupt play. Artwork files and collection components are retained. A short Day X indicator replaces the timer during the 0.4-second entrance, with the same heart temporarily disabled. Once fully visible and released input is observed, the screen enables input and starts the unchanged 10-second workday. Reward/event/relic/story/home/results designs and illustrations are unchanged. Reduced motion keeps its existing behavior; the short input-safety delay remains.

## v0.4 Cozy Pixel Arcade

FlightStyle remains the single shared design system: warm cream, burgundy outlines, bright rose faces, blush secondary surfaces, compact 5-pixel corners and hard offset depth rather than blurred shadows. `card()` frames panels and reward tiles; `button_style()` shifts label padding and reduces depth while pressed; `style_button()` adds the common release sheen. `utility()` keeps secondary navigation compact, icon-first and at least 52 logical pixels high. The heart asset, hit area and squash animation are unchanged.

Baloo 2 is bundled with its OFL license in assets/fonts. FontVariation resources choose Medium 500 (prose), SemiBold 600 (labels/metadata), Bold 700 (primary actions/card titles) and ExtraBold 800 (headings). Adjust the shared resources or FlightStyle font constants to change the hierarchy; FlightScreen.label_text and the item detail label helper apply heading/metadata roles. The inherited theme covers sliders, toggles, tooltips and dynamically created labels.

All mapped illustrations are retained. FlightArt now uses nearest filtering consistently; smooth text remains antialiased. New pause/home pixel icons use the existing 7x7 UI grid. Shared heart/sparkle dividers add static decoration to home, stories, Pause and keepsakes. Existing brief entrances, reward feedback and selection animations remain bounded and respect reduced motion. No continuous particle loop was added.

Pause emphasizes Resume, with compact icon-and-label Settings and Save & Main Menu beneath. The latter label is intentionally retained: the existing handler persists the run; home still starts a fresh run. This iteration changes no save/navigation rules. Existing reward selection/confirmation is retained, with no extra confirmation step.

## Split savings HUD

Gameplay uses equal-width SAVED and FLIGHT GOAL columns, aligned to opposite edges above a full-width bar. Baloo Bold currency includes grouping separators, shrinks from 24 to 16 logical pixels as needed, then wraps exceptionally long values within its own column. Captions remain visible. The source values always come directly from GameManager.money and GameManager.goal().

The number briefly changes tint on real savings increases, including passive income; the bounded 0.18-second tween is reused during rapid earnings. Progress eases toward a clamped 0–100% target over 0.16 seconds, retargeting from its current fill. Reduced motion sets the fill immediately. A single short, input-ignoring sparkle burst marks the first visible goal crossing; it never pauses work or calls a progression action. Rebuilding initializes from current savings without replaying an already-achieved goal. Existing workday settlement still owns chapter completion.

The route row above savings keeps Monterrey on the left and the chapter destination flush right, with a small nearest-filtered pixel airplane between them. Both labels wrap within equal flexible columns on narrow screens; destination strings and gameplay data are unchanged. The icon follows the existing `assets/art/ui/airplane` fallback mapping.

## Travel suitcase collection

FlightSuitcase replaces the gameplay Abilities/Keepsakes text lists. A compact drawn open case has a handle, lid seam, hinges, lining and luggage tag, using FlightStyle colors/frames. The only heading is the small PACKED MEMORIES caption. Empty cases show a muted airplane, without item names or “None yet.” Abilities occupy the first wrapped compartment; keepsakes occupy the second, separated by a fine seam only when both are present.

Each icon uses the existing stable-ID/explicit-texture FlightArt mapping. Fixed 56x56 buttons wrap with 6-pixel gaps; artwork is inset, tilted by a deterministic ID hash (-5 to +5 degrees) and lightly offset. Button hit areas never rotate or overlap. Tooltips and accessibility names retain item names, but no names/effects appear inline. Keyboard focus remains native. Tap signals route to the unchanged exact-effect FlightItemDetails modal.

The internal viewport grows from 56 to 128 logical pixels, then scrolls vertically; outer gameplay scrolling still handles short screens. Every owned ID appears once and remains reachable. Suitcase geometry does not depend on texture dimensions, and no physics/idle animation loop is used.

FlightScreen retains only a local last-rendered collection/level map. Newly acquired items or level increases pop their artwork from 65% to full scale over 0.24 seconds while fading in; reduced motion skips it. First rendering/restoration does not replay acquisition animations. The animation never delays workday startup or modifies items. Local history is not saved; collection contents still come entirely from GameManager.
