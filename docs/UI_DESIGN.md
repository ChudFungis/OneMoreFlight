# Version 0.3 — presentation system

The game pairs chunky original pixel objects with a warm, modern interface: cream background, warm-white cards, blush borders, dusty-rose text, burgundy actions and restrained shadows. Godot's readable bundled default font avoids a heavy pixel font or additional dependency.

## Components and scene reuse

No `.tscn` files were replaced or modified. Existing main, game, main menu, settings, pause and ending entry points retain their persistent screen/overlay hosts and four autoloads.

- `scripts/ui/main.gd` applies the shared theme and loads the presentation preference.
- `scripts/ui/flight_style.gd` centralizes colors, shapes, spacing and principal transition durations; its ConfigFile stores only Reduced motion.
- `scripts/ui/flight_art.gd` resolves explicit textures and stable filenames, preserves aspect ratios and supplies fallback art.
- `scripts/ui/flight_screen.gd` builds the local heart, choice cards, event scenes, status details and short feedback animations.

The workday's text-free heart has a fixed 250-pixel logical hit area. Only its image compresses and springs back, so fast taps do not chase a moving input target. The existing pressed signal calls GameManager.tap once. Earnings labels use the earned signal's actual amount, rendered to cents; UI randomness never consumes campaign RNG. Small optional sparkles appear every sixth successful tap, with a stronger combo tint. Floating labels expire quickly, and optional particles are suppressed during heavy input.

Workday status prioritizes destination/chapter/day, savings goal, compact progress, remaining seconds, heart, combo and burst count. Ability and relic details expand on request.

Upgrade/relic choices use three compact illustrated rows on phones, or three columns at logical widths >=720. All offered cards remain visible together at the tested portrait sizes. Every card is a touch target; tapping highlights it and enables one confirmation. Other cards dim. Confirmation calls the existing action and persists immediately; short celebrations never own gameplay state. A reload before confirmation restores the same mandatory offer without a highlight. A reload after confirmation restores the committed next phase.

Event scenes retain the original short prose and choices. Reward lines show gifts including the current event amplifier/earnings relic, and burst additions including the shared charge capacity. A single-outcome definition uses Continue. Relics use richer cards, larger art and a permanent-effect badge; the selected relic gets a brief extra sparkle celebration. Travel keeps the existing story sequence and adds a compact banner.

Reduced motion in Settings suppresses positional/scaling/card-entry animation, tint pulses and optional sparkles. Short opacity-only feedback remains. The preference lives in `user://presentation.cfg`, separate from the unchanged campaign save schema. Menus remain responsive while gameplay is paused.

## Artwork

New directories: `assets/art/heart/`, `events/`, and `ui/`. Existing `upgrades/` and `relics/` now contain an individual square SVG for every stable content ID; existing `story/` placeholders are unchanged. There are 29 new SVGs: one heart, 12 upgrade illustrations, eight event illustrations, six relic illustrations and two reusable decorations. See ARTWORK.md for every filename, recommended dimensions and the PNG/WebP replacement workflow.

## Practical limits

No browser build could be produced because matching Godot 4.7.2 Web templates are not installed. The existing Compatibility, single-thread preset remains unchanged. Native desktop GUI tests do not establish Safari storage, input latency, notch safe areas or physical touch-target sizes. Conservative 20-pixel side/28-pixel vertical gutters and scrolling are in place; validate real device safe areas before release. 320-wide rendering is a stress check below the configured desktop minimum of 360. Future artwork and significantly longer localized text should be checked again at minimum width. No portraits, custom soundtrack or new story prose were generated.
