# Personalized artwork replacement

No portraits have been generated. Included illustrations are abstract hearts and destination cards. The game stays playable without personalized art.

Copy your images to these exact paths (PNG preferred; WebP also supported):

| Scene | File |
| --- | --- |
| Main menu / spa welcome | `assets/art/story/main_menu.png` |
| Denver reunion | `assets/art/story/denver.png` |
| Italy vacation | `assets/art/story/italy.png` |
| Moving to America / final ending | `assets/art/story/final.png` |

Recommended story size: **1200 × 800** landscape, with faces/text inside the central 80%. The portrait interface shows the entire image with aspect preserved, inside a rounded card. Transparent backgrounds are supported. Keep each file compact for mobile downloads. The same final image is used for the trip scene and ending.

Open Godot after copying so it imports the images. PNG takes priority over WebP, which takes priority over the existing SVG placeholder. Leave the SVGs as fallbacks. Missing story art renders a text/heart fallback. No script editing is required. Export again after replacing artwork.

## Upgrade icons

Use square PNGs, preferably 256 × 256, in `assets/art/upgrades/`:

`cabrito.png`, `facetime.png`, `appointment.png`, `cafecito.png`, `empire.png`, `flights.png`, `love.png`, `blessing.png`, `playlist.png`, `tips.png`, `jar.png`, `team.png`.

## Relic icons

Use square PNGs in `assets/art/relics/`:

`hoodie.png`, `unlimited.png`, `kiss.png`, `passport.png`, `bracelet.png`, `postcard.png`.

WebP/SVG also work with the same stem. Missing icons use `assets/art/icon_placeholder.svg`. Alternatively, open a definition `.tres` in Godot's Inspector and assign its **Icon** texture directly; that takes precedence over the predictable path. The Web export includes all imported resources, including path-based textures.

Story text can be edited in `resources/story.tres` through the Inspector. Preserve three entries in each chapter array. Upgrade/event/relic names and descriptions are editable in their respective `.tres` resources. Always check the smallest portrait layout after changing text.
