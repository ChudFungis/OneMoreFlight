# Replaceable artwork — v0.3

All illustrations resolve through `scripts/ui/flight_art.gd`. No portraits were generated. New placeholders are original rectangle-based SVG pixel illustrations. Existing chapter artwork and all story prose remain intact. Dimensions below are recommendations, not hardcoded texture requirements: Controls ignore source dimensions for layout and preserve aspect ratio.

| Location | Filenames (stable IDs) | Suggested replacement |
| --- | --- | --- |
| `assets/art/heart/` | `tap.png` | 384 × 336 or similar; transparent chunky heart with a little transparent padding |
| `assets/art/upgrades/` | `appointment`, `blessing`, `cabrito`, `cafecito`, `empire`, `facetime`, `flights`, `jar`, `love`, `playlist`, `tips`, `team` | 512 × 512 square PNG/WebP |
| `assets/art/events/` | `call`, `cancelled`, `dinner`, `gift`, `rain`, `repair`, `sale`, `viral` | 960 × 540 landscape PNG/WebP |
| `assets/art/relics/` | `bracelet`, `hoodie`, `kiss`, `passport`, `postcard`, `unlimited` | 512 × 512 square PNG/WebP |
| `assets/art/story/` | `main_menu`, `denver`, `italy`, `final` | 1200 × 800 landscape PNG/WebP |
| `assets/art/ui/` | `heart`, `sparkle`, `trophy`, `gear` | 64–128 px square transparent decorations |

Content names may change; filename IDs must remain stable. The existing shared fallback is `assets/art/icon_placeholder.svg`. The final story image is reused for the ending. The main heart is rendered with nearest filtering to keep pixels crisp; other images use linear filtering for future cartoon illustrations. Pixel source SVGs have aligned edges and a consistent rose/cream palette.

## Replacement workflow

1. Place a compact PNG or WebP at the listed folder with the same ID stem. For example, replace Fede's Shopping List using `assets/art/events/repair.png`; the main heart uses `assets/art/heart/tap.png`.
2. Keep the SVG in place as a fallback. Resolution order is an explicit content **Icon** texture, then PNG, WebP, SVG, then shared fallback. The optional Icon field applies to upgrades, relics and events; remove an explicit assignment if you want filenames to take precedence.
3. Open Godot and let it import the new image. No gameplay or UI script edit is required. Re-export the game afterward; the existing all-resources Web preset includes imported path-based artwork.
4. Inspect narrow portrait and desktop layouts. Images fit their frame without cropping, so keep important elements inside the central 80% and avoid embedded text. Transparent margins are supported. Landscape and square frames scale independently of original texture dimensions.

Keep replacement textures modest for phone downloads, preferably below 512 KB each when practical. SVG fallback placeholders identify every current content item; missing custom files never produce a broken-texture rectangle. UI sparkle/heart assets are available for future decoration; current transient sparkle feedback uses lightweight text glyphs.

## Shared presentation controls

`FlightStyle` centralizes colors, borders, card corners, shadows, spacing and animation durations. Godot's bundled readable default font is retained, with no external font dependency. `FlightScreen` owns layout and interactions; `FlightArt` owns artwork resolution. Existing scenes still use FlightScreen, and the persistent main scene applies FlightStyle's theme to screens and overlays.

Settings includes Reduced motion. It is saved separately in `user://presentation.cfg`, leaving campaign snapshots and the v0.2 SaveManager unchanged. It suppresses heart scaling, image/card entrances, combo tint pulses, drifting earnings and optional sparkles. Feedback remains visible with short opacity fades; decision controls never wait for an animation.

### v0.4 UI treatment

The existing heart and all content illustrations are unchanged. UI pixel assets now also include `pause.svg`, `home.svg`, `toggle_on.svg`, `toggle_off.svg` and `knob.svg`. These use the same burgundy/rose grid treatment as existing utility icons. All FlightArt images use nearest texture filtering; fonts stay smoothly antialiased. Existing explicit texture > PNG > WebP > SVG > fallback resolution remains intact.

The travel suitcase frame is drawn by `scripts/ui/flight_suitcase.gd` from shared palette/StyleBox tokens (handle, hinges, lid seam and tag). Item art remains unmodified and uses the same explicit texture/PNG/WebP/SVG resolution. Slight artwork tilts are presentation-only; icon touch targets remain axis-aligned and fixed. The empty case reuses `ui/airplane`.

## Ability Resource filenames

Resource files use readable ability names. Artwork paths and save IDs remain stable; rename neither when editing a title.

| Resource file in resources/upgrades | Stable ID / artwork stem |
| --- | --- |
| `gringo_influence.tres` | `appointment` |
| `cabrito_power.tres` | `cabrito` |
| `facetime_date.tres` | `facetime` |
| `volaris_red_eye.tres` | `flights` |
| `passive_income_princess.tres` | `jar` |
| `nicky_mode.tres` | `love` |
| `norteno_playlist.tres` | `playlist` |
| `well_rested.tres` | `team` |
| `one_wish_willow.tres` | `tips` |
